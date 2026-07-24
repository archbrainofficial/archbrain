import 'package:flutter/material.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreeIMEI = true;
  bool _agreeGPS = true;
  bool _agreePrivacy = true;

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
            const Text(
              'TERMS & CONSENT',
              style: TextStyle(
                color: Color(0xFF22D3EE),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Before We Begin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'ARCHBRAIN needs your permission to collect your device IMEI and GPS location to enable tracking and recovery. Your data is encrypted and NDPR compliant.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 30),
            // Checkbox List Items
            _buildCheckboxItem(
              'I agree to collect my device IMEI number for tracking',
              _agreeIMEI,
              (val) => setState(() => _agreeIMEI = val),
            ),
            const SizedBox(height: 16),
            _buildCheckboxItem(
              'I agree to real-time GPS location updates',
              _agreeGPS,
              (val) => setState(() => _agreeGPS = val),
            ),
            const SizedBox(height: 16),
            _buildCheckboxItem(
              'I have read the Privacy Policy',
              _agreePrivacy,
              (val) => setState(() => _agreePrivacy = val),
            ),
            const Spacer(),
            // Action Buttons
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
                  if (_agreeIMEI && _agreeGPS && _agreePrivacy) {
                    Navigator.pushReplacementNamed(context, '/imei');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please accept all consent items to proceed.')),
                    );
                  }
                },
                child: const Text('I Agree — Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Decline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxItem(String text, bool isChecked, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isChecked ? const Color(0xFF22D3EE) : Colors.transparent,
              border: Border.all(color: isChecked ? const Color(0xFF22D3EE) : Colors.white24),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isChecked
                ? const Icon(Icons.check, size: 12, color: Colors.black)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isChecked ? Colors.white : Colors.white60,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
