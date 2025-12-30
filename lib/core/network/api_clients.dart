// lib/core/network/api_client.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:zest_employee/core/utils/token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;

  ApiException(this.statusCode, this.message, {this.details});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final http.Client _client;
  final TokenStorage _tokenStorage;
  final Duration timeout;

  ApiClient({
    required http.Client client,
    required TokenStorage tokenStorage,
    this.timeout = const Duration(seconds: 15),
  })  : _client = client,
        _tokenStorage = tokenStorage;

  /// Build URI (supports full URL + query params)
  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final uri = Uri.parse(path);
    if (queryParameters == null || queryParameters.isEmpty) return uri;
    return uri.replace(queryParameters: queryParameters);
  }

  /// Default headers with optional token
  Future<Map<String, String>> _defaultHeaders([String? token]) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final t = token ?? await _tokenStorage.readToken();
    if (t != null && t.isNotEmpty) {
      headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  Future<dynamic> _sendRequest(Future<http.Response> futureRes) async {
    final http.Response res = await futureRes.timeout(timeout);

    final body = res.body.isNotEmpty ? res.body : null;
    dynamic decoded;

    if (body != null) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = body;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }

    String message = 'Request failed: ${res.statusCode}';
    if (decoded is Map<String, dynamic>) {
      message = decoded['message']?.toString() ??
          decoded['error']?.toString() ??
          message;
    }

    throw ApiException(res.statusCode, message, details: decoded);
  }


  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    String? token,
  }) async {
    final uri = _uri(path, queryParameters);
    final headers = await _defaultHeaders(token);
    return _sendRequest(_client.get(uri, headers: headers));
  }

  Future<dynamic> post(String path, {dynamic body, String? token}) async {
    final uri = _uri(path);
    final headers = await _defaultHeaders(token);
    return _sendRequest(
      _client.post(uri, headers: headers, body: jsonEncode(body)),
    );
  }

  Future<dynamic> put(String path, {dynamic body, String? token}) async {
    final uri = _uri(path);
    final headers = await _defaultHeaders(token);
    return _sendRequest(
      _client.put(uri, headers: headers, body: jsonEncode(body)),
    );
  }

  Future<dynamic> delete(String path, {dynamic body, String? token}) async {
    final uri = _uri(path);
    final headers = await _defaultHeaders(token);
    return _sendRequest(
      _client.delete(uri, headers: headers, body: jsonEncode(body)),
    );
  }

  Future<dynamic> request(
    String method,
    String path, {
    dynamic body,
    Map<String, String>? extraHeaders,
    String? token,
  }) async {
    final uri = _uri(path);
    final headers = await _defaultHeaders(token);
    if (extraHeaders != null) headers.addAll(extraHeaders);

    final req = http.Request(method.toUpperCase(), uri)
      ..headers.addAll(headers)
      ..body = body == null ? '' : jsonEncode(body);

    final streamed = await _client.send(req).timeout(timeout);
    final response = await http.Response.fromStream(streamed);
    return _sendRequest(Future.value(response));
  }


  Future<dynamic> multipartRequest(
    String method,
    String path, {
    required Map<String, String> fields,
    List<http.MultipartFile> files = const [],
    String? token,
  }) async {
    final uri = _uri(path);
    final headers = await _defaultHeaders(token);

    headers.remove('Content-Type');

    final request = http.MultipartRequest(method.toUpperCase(), uri);
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    request.files.addAll(files);

    final streamed = await _client.send(request).timeout(timeout);
    final response = await http.Response.fromStream(streamed);

    return _sendRequest(Future.value(response));
  }

  Future<dynamic> multipartPut(
    String path, {
    required Map<String, String> fields,
    File? file,
    String? fileKey,
    String? token,
  }) async {
    final files = <http.MultipartFile>[];

    if (file != null && fileKey != null) {
      files.add(await http.MultipartFile.fromPath(fileKey, file.path));
    }

    return multipartRequest(
      'PUT',
      path,
      fields: fields,
      files: files,
      token: token,
    );
  }
}
