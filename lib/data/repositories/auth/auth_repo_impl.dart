import 'dart:io';

import 'package:zest_employee/data/models/auth_results.dart';
import 'package:zest_employee/data/models/notification_model.dart';
import 'package:zest_employee/data/repositories/auth/auth_repo.dart';
import 'package:zest_employee/core/utils/token_storage.dart';
import 'package:zest_employee/data/data_providers/auth/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;
  final TokenStorage _storage;

  AuthRepositoryImpl({required AuthApi api, required TokenStorage storage})
    : _api = api,
      _storage = storage;

  @override
  Future<AuthResult> login(String email, String password) async {
    final res = await _api.login(email: email, password: password);

    await _storage.saveToken(res.accessToken);
    await _storage.saveRefreshToken(res.refreshToken);
    await _storage.saveUserJson(res.employee.toJson());
    _api.saveToken();

    return res;
  }

  @override
  Future<AuthResult> signup(
    String email,
    String password, {
    String? name,
  }) async {
    final res = await _api.signup(email: email, password: password, name: name);

    await _storage.saveToken(res.accessToken);

    if (res.refreshToken.isNotEmpty) {
      await _storage.saveRefreshToken(res.refreshToken);
    }

    await _storage.saveUserJson(res.employee.toJson());

    return res;
  }

  @override
  Future<AuthResult?> restoreSession() async {
    final token = await _storage.readToken();

    if (token == null || token.isEmpty) return null;

    try {
      final res = await _api.me(token);

      await _storage.saveUserJson(res.employee.toJson());

      return res;
    } catch (e) {
      await _storage.clear();
      return null;
    }
  }

  @override
  Future<NotificationResponse> getNotifications() async {
    final res = await _api.getNotification();

    if (!res.success) {
      return NotificationResponse(
        success: false,
        total: 0,
        page: 0,
        totalPages: 0,
        notifications: [],
      );
    }

    return res;
  }

  @override
  Future<void> logout() async {
    await _storage.clear();
  }

  @override
  Future<AuthResult> updateProfile({
    required String employeeId,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String position,
    String? password,
    File? profileImage,
  }) async {
    final token = await _storage.readToken();

    final res = await _api.updateProfile(
      employeeId: employeeId,
      token: token!,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      position: position,
      password: password,
      profileImage: profileImage,
    );

    await _storage.saveUserJson(res.employee.toJson());
    return res;
  }
}
