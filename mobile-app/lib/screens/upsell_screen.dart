import 'package:flutter/material.dart';

class UpsellScreen extends StatelessWidget {
  const UpsellScreen({super.key});

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
            const SizedBox(height: 20),
            // ✓ Device Registered Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                  SizedBox(width: 6),
                  Text(
                    'DEVICE REGISTERED',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your phone is protected!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You are on the Free Plan. Upgrade for full protection:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 30),
            // Premium features checklist
            Expanded(
              child: ListView(
                children: [
                  _buildFeatureRow('GPS update speed', '30 sec', true),
                  _buildFeatureRow('Remote wipe', 'Yes', true),
                  _buildFeatureRow('SMS alerts', 'Yes', true),
                  _buildFeatureRow('Location history', '90 days', false),
                  _buildFeatureRow('Devices protected', '10', false),
                ],
              ),
            ),
            // Price Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text(
                    '₦2,500/mo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '= ₦83/day - less than a bottle of water',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Upgrade Buttons
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22D3EE),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: const Text('Upgrade to Premium', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  foregroundColor: Colors.white60,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: const Text('Stay on Free', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String label, String value, bool isIcon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          isIcon && value == 'Yes'
              ? const Icon(Icons.check, size: 16, color: Color(0xFF22D3EE))
              : Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
        ],
      ),
    );
  }
}
