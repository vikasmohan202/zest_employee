import 'dart:io';
import 'package:zest_employee/core/constants/api_end_point.dart';
import 'package:zest_employee/core/network/api_clients.dart';
import 'package:zest_employee/data/data_providers/auth/auth_api.dart';
import 'package:zest_employee/data/models/auth_results.dart';
import 'package:zest_employee/data/models/notification_model.dart';

class HttpAuthApi implements AuthApi {
  final ApiClient _api;
  HttpAuthApi(this._api);

  @override
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final String input = email.trim();

    /// Decide payload key
    final Map<String, dynamic> body = {
      if (input.contains('@')) 'email': input else 'phoneNumber': input,
      'password': password,
    };

    final json = await _api.post(
      Endpoints.baseUrl + Endpoints.login,
      body: body,
    );

    return AuthResult.fromJson(json);
  }

  @override
  Future<AuthResult> signup({
    required String email,
    required String password,
    String? name,
  }) async {
    final json = await _api.post(
      Endpoints.baseUrl + Endpoints.signup,
      body: {'email': email, 'password': password, 'name': name},
    );
    return AuthResult.fromJson(json);
  }

  @override
  Future<AuthResult> me(String token) async {
    final json = await _api.get(
      Endpoints.baseUrl + Endpoints.profile,
      token: token,
    );
    return AuthResult.fromJson(json);
  }

  @override
  Future<NotificationResponse> getNotification() async {
    final json = await _api.get(Endpoints.baseUrl + Endpoints.getNotifications);
    return NotificationResponse.fromJson(json);
  }

  // 🔥 UPDATE PROFILE
  @override
  Future<AuthResult> updateProfile({
    required String employeeId,
    required String token,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String position,
    String? password,
    File? profileImage,
  }) async {
    final url = "${Endpoints.baseUrl}${Endpoints.updateEmployee}/$employeeId";

    final json = await _api.multipartPut(
      url,
      token: token,
      fields: {
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'position': position,
        if (password != null && password.isNotEmpty) 'password': password,
      },
      file: profileImage,
      fileKey: "profileImage",
    );

    return AuthResult.fromJson(json);
  }
}
