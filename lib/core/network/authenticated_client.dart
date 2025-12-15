// lib/core/network/authenticated_client.dart
import 'dart:async';
import 'package:http/http.dart' as http;
import '../utils/token_storage.dart';

/// A BaseClient wrapper that attaches Authorization header automatically.
/// Use this client for endpoints that require authentication (home, profile, etc).
class AuthenticatedClient extends http.BaseClient {
  final http.Client _inner;
  final TokenStorage _tokenStorage;

  AuthenticatedClient(this._inner, this._tokenStorage);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await _tokenStorage.readToken();

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // If you want a default content-type for JSON:
    request.headers.putIfAbsent('Content-Type', () => 'application/json');

    return _inner.send(request);
  }
}
