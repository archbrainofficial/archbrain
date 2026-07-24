import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final _storage = const FlutterSecureStorage();

  Future<bool> register(String name, String email, String phone, String password) async {
    try {
      final response = await _api.post('/auth/register', {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'auth_token', value: data['token']);
        await _storage.write(key: 'user_info', value: jsonEncode(data['user']));
        return true;
      }

      // Log response details for debugging signup failures
      print('Signup failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (error) {
      print('Signup exception: $error');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'auth_token', value: data['token']);
        await _storage.write(key: 'user_info', value: jsonEncode(data['user']));
        return true;
      }

      // Log response details for debugging login failures
      print('Login failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (error) {
      print('Login exception: $error');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_info');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    final info = await _storage.read(key: 'user_info');
    if (info == null) return null;
    try {
      return User.fromJson(jsonDecode(info));
    } catch (_) {
      return null;
    }
  }
}
