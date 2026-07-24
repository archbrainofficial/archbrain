import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/device.dart';
import 'api_service.dart';

class DeviceService {
  final ApiService _api = ApiService();
  final _storage = const FlutterSecureStorage();

  Future<Device?> registerDevice(String imei, String model, String osVersion) async {
    try {
      final response = await _api.post('/device/register-device', {
        'imei': imei,
        'model': model,
        'os_version': osVersion,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final device = Device.fromJson(data['device']);
        await _storage.write(key: 'device_id', value: device.id);
        return device;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> recordConsent(String deviceId, bool consentGiven) async {
    try {
      final response = await _api.post('/consent/record-consent', {
        'device_id': deviceId,
        'consent_given': consentGiven,
      });
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
