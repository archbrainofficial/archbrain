import 'package:flutter/material.dart';

class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      appBar: AppBar(
        title: const Text('Security Incident'),
        backgroundColor: const Color(0xFF0A0F1D),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone Possibly Stolen warning banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.25)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.error_outline, color: Color(0xFFF87171), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Phone Possibly Stolen',
                        style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your Samsung A54 moved 2km from your home zone at 11:42 PM. SIM card changed detected.',
                    style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Last seen location card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.near_me, color: Color(0xFF60A5FA), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Last seen: Oshodi Market, Lagos',
                    style: TextStyle(color: Color(0xFF60A5FA), fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Free plan: lock only. Upgrade to wipe your data instantly and protect your bank apps.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
            ),
            const Spacer(),
            // Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF43F5E), // Rose pink/red button
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  // Simulate upgrade & wipe triggering
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing payment via Paystack...')),
                  );
                },
                child: const Text('Upgrade & Wipe Now — ₦2,500', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lock screen command sent.')),
                  );
                },
                child: const Text('Lock Only (Free)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Cancel anytime · Charged via Paystack',
                style: TextStyle(color: Colors.white30, fontSize: 10),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
