// lib/data_providers/auth_api_impl.dart
import 'package:zest_employee/core/constants/api_end_point.dart';
import 'package:zest_employee/core/network/api_clients.dart';
import 'package:zest_employee/data/data_providers/auth/auth_api.dart';
import 'package:zest_employee/data/models/auth_results.dart';


class HttpAuthApi implements AuthApi {
  final ApiClient _api;

  HttpAuthApi(this._api);

  @override
  Future<AuthResult> login({required String email, required String password}) async {
    final json = await _api.post(Endpoints.baseUrl + Endpoints.login,
        body: {'email': email, 'password': password});
    return AuthResult.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<AuthResult> signup({required String email, required String password, String? name}) async {
    final json = await _api.post(Endpoints.baseUrl + Endpoints.signup,
        body: {'email': email, 'password': password, 'name': name});
    return AuthResult.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<AuthResult> me(String token) async {
    final json =
        await _api.get(Endpoints.baseUrl + Endpoints.profile, token: token);
    return AuthResult.fromJson(json as Map<String, dynamic>);
  }
}
