import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class TokenManager {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await storage.delete(key: _tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> saveUser(Map<String, dynamic> userData) async {
    await storage.write(key: _userKey, value: jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final userJson = await storage.read(key: _userKey);
    if (userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> deleteUser() async {
    await storage.delete(key: _userKey);
  }

  static Future<void> clearAuth() async {
    await deleteToken();
    await deleteUser();
  }
}
