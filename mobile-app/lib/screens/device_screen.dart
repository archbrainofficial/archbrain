import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceScreen extends StatelessWidget {
  final Device device;
  const DeviceScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      appBar: AppBar(
        title: Text(device.model),
        backgroundColor: const Color(0xFF0A0F1D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.phone_android, size: 80, color: Color(0xFF00F2FE)),
                  const SizedBox(height: 10),
                  Text(device.model, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text('OS: ${device.osVersion}', style: const TextStyle(color: Colors.white60, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildDetailRow('IMEI', device.imei),
            _buildDetailRow('Status', device.status.toUpperCase()),
            _buildDetailRow('Battery Level', '${device.batteryLevel}%'),
            _buildDetailRow('Data Link', 'AES-256 Encrypted'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Trigger local Lost/Stolen wizard
                  debugPrint("REPORTING DEVICE LOST");
                },
                child: const Text('Report Stolen / Lock Device', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
