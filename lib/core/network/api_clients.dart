// lib/core/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zest_employee/core/utils/token_storage.dart';

/// Generic API exception thrown by ApiClient
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
  }) : _client = client,
       _tokenStorage = tokenStorage;

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    // If path already contains full URL, Uri.parse will work fine.
    // Otherwise, keep using your Endpoints.baseUrl + path externally.
    if (path.startsWith('http')) return Uri.parse(path);
    return Uri.parse(path);
  }

  Future<Map<String, String>> _defaultHeaders([String? token]) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final t = token ?? await _tokenStorage.readToken();
    print(t);
    if (t != null && t.isNotEmpty) {
      headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  // Generic request helper returning decoded JSON (dynamic)
  Future<dynamic> _sendRequest(Future<http.Response> futureRes) async {
    final http.Response res = await futureRes.timeout(timeout);

    final body = res.body.isNotEmpty ? res.body : null;
    dynamic decoded;
    if (body != null && body.isNotEmpty) {
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = body; // non-json response (string)
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }

    // Attempt to extract message from body
    String message = 'Request failed: ${res.statusCode}';
    try {
      if (decoded is Map<String, dynamic> && decoded.containsKey('message')) {
        message = decoded['message'].toString();
      } else if (decoded is Map && decoded.containsKey('error')) {
        message = decoded['error'].toString();
      } else if (body != null && body.isNotEmpty) {
        message = body;
      }
    } catch (_) {}

    throw ApiException(res.statusCode, message, details: decoded);
  }

  /// GET request. `path` can be a full URL or a relative path (build the Uri before calling).
  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    String? token,
  }) async {
    final uri = _uri(path, queryParameters);
    final headers = await _defaultHeaders(token);
    final req = _client.get(uri, headers: headers);
    return _sendRequest(req);
  }

  /// POST JSON. `body` should be encodable (Map/List).
  Future<dynamic> post(String path, {dynamic body, String? token}) async {
    final uri = _uri(path);
    final headers = await _defaultHeaders(token);
    final encoded = body == null ? null : jsonEncode(body);
    final req = _client.post(uri, headers: headers, body: encoded);
    return _sendRequest(req);
  }

  /// PUT JSON.
  Future<dynamic> put(String path, {dynamic body, String? token}) async {
    final uri = _uri(path);
    final headers = await _defaultHeaders(token);
    final encoded = body == null ? null : jsonEncode(body);
    final req = _client.put(uri, headers: headers, body: encoded);
    return _sendRequest(req);
  }

  /// DELETE (optionally with body)
  Future<dynamic> delete(String path, {dynamic body, String? token}) async {
    final uri = _uri(path);
    final headers = await _defaultHeaders(token);
    final encoded = body == null ? null : jsonEncode(body);
    // http package has delete with body in recent versions; otherwise use Request
    final req = _client.delete(uri, headers: headers, body: encoded);
    return _sendRequest(req);
  }

  /// Generic request with custom method and optional body
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

    final encoded = body == null ? null : jsonEncode(body);
    final request = http.Request(method.toUpperCase(), uri);
    request.headers.addAll(headers);
    if (encoded != null) request.body = encoded;

    final streamed = await _client.send(request).timeout(timeout);
    final response = await http.Response.fromStream(streamed);
    return _sendRequest(Future.value(response));
  }

  /// Multipart file upload
  Future<dynamic> uploadMultipart(
    String path, {
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    String? token,
  }) async {
    final uri = _uri(path);
    final headers = await _defaultHeaders(token);
    // Remove content-type header so multipart sets boundary correctly
    headers.remove('Content-Type');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    request.files.addAll(files);

    final streamed = await _client.send(request).timeout(timeout);
    final response = await http.Response.fromStream(streamed);
    return _sendRequest(Future.value(response));
  }
}
