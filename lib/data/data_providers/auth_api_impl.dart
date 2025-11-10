import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:zest_employee/core/constants/constant.dart';
import 'package:zest_employee/data/models/auth_results.dart';

import 'auth_api.dart';

class HttpAuthApi implements AuthApi {
  final http.Client _client;

  HttpAuthApi(this._client);

  Uri _u(String path) => Uri.parse(Endpoints.baseUrl + path);

  Map<String, String> _headers([String? token]) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    final res = await _client.post(_u(Endpoints.login),
        headers: _headers(), body: jsonEncode({'email': email, 'password': password}));
    return _parse(res);
  }

  @override
  Future<AuthResult> signup({required String email, required String password, String? name}) async {
    final res = await _client.post(_u(Endpoints.signup),
        headers: _headers(), body: jsonEncode({'email': email, 'password': password, 'name': name}));
    return _parse(res);
  }

  @override
  Future<AuthResult> me(String token) async {
    final res = await _client.get(_u(Endpoints.profile), headers: _headers(token));
    return _parse(res);
  }

  AuthResult _parse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return AuthResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    }
    debugPrint('Auth API error: ${res.statusCode} ${res.body}');
    throw Exception(jsonDecode(res.body)['message'] ?? 'Authentication failed');
  }
}
