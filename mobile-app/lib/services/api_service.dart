import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static String get baseUrl {
    // On web platform, always use localhost
    if (kIsWeb) {
      return 'http://localhost:3005/api';
    }
    // On mobile/other platforms, use localhost (will be updated for Android if needed)
    return 'http://localhost:3005/api';
  }

  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    final headers = await _getHeaders();
    return http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path) async {
    final headers = await _getHeaders();
    return http.delete(Uri.parse('$baseUrl$path'), headers: headers);
  }
}
