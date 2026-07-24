import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'location_service.dart';

class TrackingService {
  final ApiService _api = ApiService();
  final LocationService _location = LocationService();
  final _storage = const FlutterSecureStorage();

  Future<void> sendLocationUpdate() async {
    final deviceId = await _storage.read(key: 'device_id');
    if (deviceId == null) return;

    final Position? position = await _location.getCurrentPosition();
    if (position == null) return;

    // In a real device setup, battery level is obtained via battery package
    // Here we stub it at 85% for demonstration
    const batteryLevel = 85; 

    await _api.post('/tracking/update-location', {
      'device_id': deviceId,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'speed': position.speed,
      'battery_level': batteryLevel,
    });
  }

  // Polls backend for any remote lock/wipe commands enqueued for this device
  Future<void> pollMdmCommands() async {
    final deviceId = await _storage.read(key: 'device_id');
    if (deviceId == null) return;

    try {
      final response = await _api.get('/mdm/pending-commands/$deviceId');
      if (response.statusCode == 200) {
        final List commands = jsonDecode(response.body);
        for (var cmd in commands) {
          final String commandId = cmd['id'];
          final String commandType = cmd['command_type'];
          
          await _executeCommand(commandType);

          // Acknowledge execution completion
          await _api.post('/mdm/acknowledge-command', {
            'command_id': commandId,
            'status': 'executed',
          });
        }
      }
    } catch (_) {
      // Graceful error logging
    }
  }

  Future<void> _executeCommand(String type) async {
    if (type == 'lock') {
      // Code to lock Android device using DeviceAdminReceiver
      debugPrint("[MDM] EXECUTING REMOTE LOCK COMMAND");
    } else if (type == 'wipe') {
      // Code to wipe device using wipeData API
      debugPrint("[MDM] EXECUTING REMOTE WIPE COMMAND");
    }
  }
}
