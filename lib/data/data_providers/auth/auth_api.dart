import 'package:zest_employee/data/models/auth_results.dart';


abstract class AuthApi {
  Future<AuthResult> login({required String email, required String password});
  Future<AuthResult> signup({required String email, required String password, String? name});
  Future<AuthResult> me(String token);
}
