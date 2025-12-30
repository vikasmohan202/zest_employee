import 'package:zest_employee/core/utils/token_storage.dart';
import 'package:zest_employee/data/models/admin_model.dart';

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final Admin employee;

  AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.employee,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final token =  TokenStorage().readToken();
     final reToken=TokenStorage().readRefreshToken();
    final accessToken = (json['accessToken'] ?? token).toString();
    final refreshToken = (json['refreshToken'] ?? reToken).toString();

    // Now the user data is inside "employee"
    final userMap = (json['employee'] ?? {}) as Map<String, dynamic>;

    return AuthResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      employee: Admin.fromJson(userMap),
    );
  }
}
