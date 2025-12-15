import 'package:zest_employee/data/models/auth_results.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> signup(String email, String password, {String? name});
  Future<AuthResult?> restoreSession(); 
  Future<void> logout();
}
