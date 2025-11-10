import 'package:http/http.dart' as http;
import 'package:zest_employee/data/models/auth_results.dart';
import 'package:zest_employee/data/repositories/auth_repo.dart';
import '../../core/utils/token_storage.dart';
import '../data_providers/auth_api.dart';
import '../data_providers/auth_api_impl.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;
  final TokenStorage _storage;

  AuthRepositoryImpl({AuthApi? api, TokenStorage? storage})
      : _api = api ?? HttpAuthApi(http.Client()),
        _storage = storage ?? TokenStorage();

  @override
  Future<AuthResult> login(String email, String password) async {
    final res = await _api.login(email: email, password: password);
    await _storage.saveToken(res.token);
    return res;
    }

  @override
  Future<AuthResult> signup(String email, String password, {String? name}) async {
    final res = await _api.signup(email: email, password: password, name: name);
    await _storage.saveToken(res.token);
    return res;
  }

  @override
  Future<AuthResult?> restoreSession() async {
    final token = await _storage.readToken();
    if (token == null) return null;
    final res = await _api.me(token);
    return res;
  }

  @override
  Future<void> logout() => _storage.clear();
}
