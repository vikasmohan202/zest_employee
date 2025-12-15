import 'package:zest_employee/data/models/auth_results.dart';
import 'package:zest_employee/data/repositories/auth/auth_repo.dart';
import 'package:zest_employee/core/utils/token_storage.dart';
import 'package:zest_employee/data/data_providers/auth/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;
  final TokenStorage _storage;

  AuthRepositoryImpl({
    required AuthApi api,
    required TokenStorage storage,
  })  : _api = api,
        _storage = storage;

  @override
  Future<AuthResult> login(String email, String password) async {
    final res = await _api.login(email: email, password: password);

    await _storage.saveToken(res.accessToken);
    await _storage.saveRefreshToken(res.refreshToken);
    await _storage.saveUserJson(res.employee.toJson());

    return res;
  }

  @override
  Future<AuthResult> signup(
    String email,
    String password, {
    String? name,
  }) async {
    final res = await _api.signup(
      email: email,
      password: password,
      name: name,
    );

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
  Future<void> logout() async {
    await _storage.clear();
  }
}
