import 'dart:io';
import 'package:zest_employee/data/models/auth_results.dart';
import 'package:zest_employee/data/models/notification_model.dart';

abstract class AuthApi {
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> signup({required String email, required String password, String? name});
  Future<AuthResult> me(String token);
  Future<NotificationResponse> getNotification();

  Future<AuthResult> updateProfile({
    required String employeeId,
    required String token,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String position,
    String? password,
    File? profileImage,
  });
}
