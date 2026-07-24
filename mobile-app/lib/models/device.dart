class Device {
  final String id;
  final String userId;
  final String imei;
  final String model;
  final String osVersion;
  final int batteryLevel;
  final String status;

  Device({
    required this.id,
    required this.userId,
    required this.imei,
    required this.model,
    required this.osVersion,
    required this.batteryLevel,
    required this.status,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      imei: json['imei'] ?? '',
      model: json['model'] ?? '',
      osVersion: json['os_version'] ?? '',
      batteryLevel: json['battery_level'] ?? 100,
      status: json['status'] ?? 'online',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'imei': imei,
      'model': model,
      'os_version': osVersion,
      'battery_level': batteryLevel,
      'status': status,
    };
  }
}
