import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _profileKey = 'archbrain_profile';
  static const _imeiKey = 'archbrain_imei';
  static const _accountCreatedKey = 'archbrain_account_created';

  Future<Map<String, String>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveProfile(Map<String, String> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile));
  }

  Future<String> loadImei() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_imeiKey) ?? '';
  }

  Future<void> saveImei(String imei) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_imeiKey, imei);
  }

  Future<void> setAccountCreated(bool created) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_accountCreatedKey, created);
  }

  Future<bool> hasAccount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_accountCreatedKey) ?? false;
  }
}
