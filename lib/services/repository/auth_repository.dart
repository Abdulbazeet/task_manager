import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tasks/core/token_manager.dart';
import 'package:tasks/models/user.dart';
import '../../config/exception.dart';

class AuthRepository {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // static const String baseUrl =
  //     'https://taskmanager-production-dee.up.railway.app/api';



  // REgister
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['data']['token'] as String;
        final userData = data['data'] as Map<String, dynamic>;
        await TokenManager.saveToken(token);
        await TokenManager.saveUser(userData);
        return userData;
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
          data['message'] ?? 'Validation failed',
          statusCode: 422,
        );
      } else {
        throw ApiException(
          'Registration failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['data']['token'] as String;
        final userData = data['data'] as Map<String, dynamic>;
        await TokenManager.saveToken(token);
        await TokenManager.saveUser(userData);
        return userData;
      } else if (response.statusCode == 401) {
        throw ApiException('Invalid email or password', statusCode: 401);
      } else {
        throw ApiException('Login failed', statusCode: response.statusCode);
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await TokenManager.getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/auth/logout'),
          headers: _getHeaders(token),
        );
      }
      await TokenManager.clearAuth();
    } catch (e) {
      await TokenManager.clearAuth();
      throw ApiException(e.toString());
    }
  }

  // Get current user
  Future<User> getMe() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) throw ApiException('No token found');

      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return User.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw ApiException(
          'Failed to get user',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
