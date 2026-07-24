import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/consent_screen.dart';
import 'screens/imei_input_screen.dart';
import 'screens/upsell_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/crisis_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/last_location_screen.dart';
import 'screens/live_location_screen.dart';
import 'screens/info_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArchbrainApp());
}
// Add this Luhn check to your Flutter code:
bool luhnCheck(String imei) {
  int sum = 0;
  bool alt = false;
  for (int i = imei.length - 1; i >= 0; i--) {
    int n = int.parse(imei[i]);
    if (alt) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alt = !alt;
  }
  return sum % 10 == 0;
}

String? validateIMEI(String imei) {
  if (imei.isEmpty) return 'Please enter your IMEI';
  if (!RegExp(r'^\d+$').hasMatch(imei)) {
    return 'IMEI must contain numbers only';
  }
  if (imei.length != 15) {
    return 'IMEI must be exactly 15 digits';
  }
  if (!luhnCheck(imei)) {
    return 'Invalid IMEI — please check and try again';
  }
  return null; // null = valid
}

class ArchbrainApp extends StatelessWidget {
  const ArchbrainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARCHBRAIN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0F1D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF22D3EE),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF0A0F1D),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/consent': (context) => const ConsentScreen(),
        '/imei': (context) => const ImeiInputScreen(),
        '/upsell': (context) => const UpsellScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/crisis': (context) => const CrisisScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/last-location': (context) => const LastLocationScreen(),
        '/live-location': (context) => const LiveLocationScreen(),
        '/info': (context) => const InfoScreen(),
      },
    );
  }
}
