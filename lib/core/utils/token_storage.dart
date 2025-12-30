// lib/core/utils/token_storage.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const keyAccessToken = 'zest_access_token';
const keyRefreshToken = 'zest_refresh_token';
const keyUserJson = 'zest_user_json';

class TokenStorage {
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAccessToken, token);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyAccessToken);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyRefreshToken, refreshToken);
  }

  Future<String?> readRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyRefreshToken);
  }

  Future<void> saveUserJson(Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserJson, jsonEncode(userJson));
  }

  Future<Map<String, dynamic>?> readUserJson() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyUserJson);
    if (jsonStr == null) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyAccessToken);
    await prefs.remove(keyRefreshToken);
    await prefs.remove(keyUserJson);
  }
}
