import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Smart brain logo inside box mockup
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF22D3EE).withValues(alpha: 0.08),
                border: Border.all(color: const Color(0xFF22D3EE).withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
                    blurRadius: 20,
                  )
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.psychology, // Brain icon
                  size: 38,
                  color: Color(0xFFF43F5E), // Rose pink brain shape in logo
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ARCHBRAIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'Outfit',
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'SMART DEVICE SECURITY',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
