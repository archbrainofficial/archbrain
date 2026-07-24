import 'package:flutter/material.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Title + Notification Bell icon on right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Devices',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_outline, color: Color(0xFF22D3EE)),
                      onPressed: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Color(0xFFF97316)),
                      onPressed: () {
                        // Navigate to the Stolen Incident / Crisis screen
                        Navigator.pushNamed(context, '/crisis');
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Devices cards list
            Expanded(
              child: ListView(
                children: [
                  _buildDeviceCard(
                    'Samsung Galaxy A54',
                    'Active',
                    'Lagos, Ikeja - 30 secs ago',
                  ),
                  const SizedBox(height: 16),
                  _buildDeviceCard(
                    'iPhone 13',
                    'Active',
                    'Lagos, VI - 2 mins ago',
                  ),
                ],
              ),
            ),
            // + Add Device Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Device', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starting new device enrollment wizard...')),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(String model, String status, String lastSeen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121829),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                model,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: Color(0xFFF43F5E)),
              const SizedBox(width: 4),
              Text(
                lastSeen,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(Icons.lock_outline, 'Lock', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lock signal sent to $model.')),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(Icons.gps_fixed, 'Find', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pinpointing coordinates for $model...')),
                  );
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton(Icons.delete_outline, 'Wipe', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Wipe command initialized for $model.')),
                  );
                }, isDanger: true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed, {bool isDanger = false}) {
    final color = isDanger ? const Color(0xFFEF4444) : const Color(0xFFF97316);
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 12),
      label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      onPressed: onPressed,
    );
  }
}
