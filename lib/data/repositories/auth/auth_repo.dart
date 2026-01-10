import 'dart:io';

import 'package:zest_employee/data/models/auth_results.dart';
import 'package:zest_employee/data/models/notification_model.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> signup(String email, String password, {String? name});
  Future<AuthResult?> restoreSession();
  Future<void> logout();
  Future<NotificationResponse> getNotifications();

  Future<AuthResult> updateProfile({
    required String employeeId,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String position,
    String? password,
    File? profileImage,
  });
}
