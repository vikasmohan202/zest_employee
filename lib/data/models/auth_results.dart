import 'package:zest_employee/data/models/user_model.dart';


class AuthResult {
  final String token;
  final User user;

  AuthResult({required this.token, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final token = (json['token'] ?? json['accessToken'] ?? '').toString();
    final userMap = (json['user'] ?? json['data'] ?? {}) as Map<String, dynamic>;
    return AuthResult(token: token, user: User.fromJson(userMap));
  }
}
