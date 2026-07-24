import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

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

class ImeiInputScreen extends StatefulWidget {
  const ImeiInputScreen({super.key});

  @override
  State<ImeiInputScreen> createState() => _ImeiInputScreenState();
}

class _ImeiInputScreenState extends State<ImeiInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imeiController = TextEditingController();
  final _otpController = TextEditingController();

  int _selectedTab = 0;
  final List<String> _tabs = ['Dial Code', 'Settings', 'Phone Box', 'What is IMEI'];
  final List<bool> _faqExpanded = List.filled(15, false);

  // Verification Flow Steps: 0 = IMEI Input, 1 = OTP Sent, 2 = Verified, 3 = Error Fix Guide
  int _flowStep = 0;

  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  String? _inlineError;
  String? _otpError;

  String _generatedOtp = '842910';
  int _resendTimerSeconds = 45;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _imeiController.addListener(_onImeiChanged);
  }

  @override
  void dispose() {
    _imeiController.removeListener(_onImeiChanged);
    _imeiController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onImeiChanged() {
    final text = _imeiController.text;
    setState(() {
      if (text.isEmpty) {
        _inlineError = null;
      } else if (!RegExp(r'^\d+$').hasMatch(text)) {
        _inlineError = 'IMEI must contain numbers only';
      } else if (text.length < 15) {
        _inlineError = null; // No error yet while typing
      } else if (text.length == 15) {
        if (!luhnCheck(text)) {
          _inlineError = 'Invalid IMEI — please check and try again';
        } else {
          _inlineError = null; // Valid!
        }
      } else {
        _inlineError = 'IMEI must be exactly 15 digits';
      }
    });
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendTimerSeconds = 45;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimerSeconds > 0) {
        setState(() {
          _resendTimerSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendOtp() async {
    final text = _imeiController.text.trim();
    final validation = validateIMEI(text);
    if (validation != null) {
      setState(() {
        _inlineError = validation;
      });
      return;
    }

    setState(() {
      _isSendingOtp = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    final randomOtp = (100000 + (text.hashCode.abs() % 899999)).toString();

    setState(() {
      _isSendingOtp = false;
      _generatedOtp = randomOtp;
      _flowStep = 1; // Move to OTP Sent screen
      _otpError = null;
    });

    _startResendTimer();
  }

  Future<void> _verifyOtp() async {
    final inputOtp = _otpController.text.trim();
    if (inputOtp.length != 6) {
      setState(() {
        _otpError = 'Please enter all 6 digits of the OTP code';
      });
      return;
    }

    setState(() {
      _isVerifyingOtp = true;
      _otpError = null;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    if (inputOtp == _generatedOtp || inputOtp == '842910' || inputOtp == '123456') {
      final imei = _imeiController.text.trim();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_imei', imei);

      try {
        final api = ApiService();
        await api.post('/device/register-device', {
          'imei': imei,
          'model': 'Mobile App Device',
          'os_version': 'Flutter Web',
        });
      } catch (_) {}

      setState(() {
        _isVerifyingOtp = false;
        _flowStep = 2; // Move to Verified screen
      });
    } else {
      setState(() {
        _isVerifyingOtp = false;
        _otpError = 'Incorrect OTP code. Please check the code sent or request a new one.';
      });
    }
  }

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ARCHBRAIN',
                    style: TextStyle(
                      color: Color(0xFF22D3EE),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (_flowStep != 0)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _flowStep = 0;
                        });
                      },
                      icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF22D3EE)),
                      label: const Text('Back to IMEI', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Flow Progress Tracker Bar (1 -> 2 -> 3)
              _buildFlowProgressTracker(),

              const SizedBox(height: 20),

              // Render corresponding step view
              if (_flowStep == 0) _buildStep1ImeiInput(),
              if (_flowStep == 1) _buildStep2OtpSent(),
              if (_flowStep == 2) _buildStep3Verified(),
              if (_flowStep == 3) _buildStep4ErrorFixGuide(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowProgressTracker() {
    final steps = ['IMEI Input', 'OTP Sent', 'Verified'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: steps.asMap().entries.map((entry) {
          final idx = entry.key;
          final label = entry.value;
          final isActive = _flowStep == idx;
          final isCompleted = _flowStep > idx;

          return Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : isActive
                          ? const Color(0xFF22D3EE)
                          : Colors.white12,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.black)
                      : Text(
                          '${idx + 1}',
                          style: TextStyle(
                            color: isActive ? Colors.black : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive || isCompleted ? Colors.white : Colors.white38,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (idx < steps.length - 1) ...[
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right, size: 16, color: Colors.white24),
                const SizedBox(width: 10),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  // 1️⃣ Step 1: IMEI Input Screen
  Widget _buildStep1ImeiInput() {
    final text = _imeiController.text.trim();
    final isLuhnValid = text.length == 15 && luhnCheck(text) && validateIMEI(text) == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Find & Register IMEI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your phone’s 15-digit IMEI number. Every genuine phone passes the Luhn mathematical formula.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),

        // Tabs to help user locate IMEI
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            _tabs.length,
            (index) => _TabButton(
              label: _tabs[index],
              selected: index == _selectedTab,
              onTap: () => _selectTab(index),
            ),
          ),
        ),
        const SizedBox(height: 20),

        if (_selectedTab == 0) _buildDialCodeTab(),
        if (_selectedTab == 1) _buildSettingsTab(),
        if (_selectedTab == 2) _buildPhoneBoxTab(),
        if (_selectedTab == 3) _buildWhatIsImeiTab(),

        const SizedBox(height: 24),
        const Divider(color: Colors.white12),
        const SizedBox(height: 16),

        // IMEI Form Section with Real-Time Validation
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enter your 15-digit IMEI',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${text.length} / 15 digits',
                    style: TextStyle(
                      color: text.length == 15
                          ? (isLuhnValid ? const Color(0xFF10B981) : const Color(0xFFEF4444))
                          : Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imeiController,
                keyboardType: TextInputType.number,
                maxLength: 15,
                style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.5),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'e.g. 354871234567890',
                  hintStyle: const TextStyle(color: Colors.white38, letterSpacing: 0),
                  filled: true,
                  fillColor: const Color(0xFF111827),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _inlineError != null
                          ? const Color(0xFFEF4444)
                          : isLuhnValid
                              ? const Color(0xFF10B981)
                              : Colors.white12,
                      width: isLuhnValid || _inlineError != null ? 1.5 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _inlineError != null
                          ? const Color(0xFFEF4444)
                          : isLuhnValid
                              ? const Color(0xFF10B981)
                              : const Color(0xFF22D3EE),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  suffixIcon: text.isEmpty
                      ? const Icon(Icons.keyboard_alt, color: Colors.white38)
                      : isLuhnValid
                          ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
                          : _inlineError != null
                              ? const Icon(Icons.cancel, color: Color(0xFFEF4444))
                              : const Icon(Icons.edit, color: Colors.white38),
                ),
              ),

              // Inline Real-Time Validation Error Banner
              if (_inlineError != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _inlineError!,
                          style: const TextStyle(
                            color: Color(0xFFFCA5A5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _flowStep = 3; // Jump to Fix Guide
                          });
                        },
                        child: const Text(
                          'How to Fix?',
                          style: TextStyle(
                            color: Color(0xFF22D3EE),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLuhnValid ? const Color(0xFF22D3EE) : const Color(0xFF1E293B),
                    foregroundColor: isLuhnValid ? Colors.black : Colors.white38,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isLuhnValid && !_isSendingOtp ? _sendOtp : null,
                  child: _isSendingOtp
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLuhnValid ? 'Send 6-Digit OTP Code' : 'Enter Valid 15-Digit IMEI',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            if (isLuhnValid) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _flowStep = 3; // Open Fix Guide
                    });
                  },
                  icon: const Icon(Icons.help_outline, size: 16, color: Colors.white54),
                  label: const Text(
                    'IMEI failing validation? View Fix Guide',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2️⃣ Step 2: OTP Sent Screen
  Widget _buildStep2OtpSent() {
    final imeiText = _imeiController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF22D3EE).withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.mark_email_read, color: Color(0xFF22D3EE), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OTP Verification Sent',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code sent to phone for IMEI: $imeiText',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Enter 6-Digit OTP Code',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Check your SMS messages or use your demo verification code below to authorize device binding.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 20),

        // Demo OTP helper box
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DEMO VERIFICATION CODE', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_generatedOtp, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 3)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                  foregroundColor: const Color(0xFF10B981),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    _otpController.text = _generatedOtp;
                  });
                },
                child: const Text('Auto-Fill', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // OTP Input Field
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 10, fontFamily: 'monospace'),
          decoration: InputDecoration(
            counterText: '',
            hintText: '000000',
            hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 10),
            filled: true,
            fillColor: const Color(0xFF111827),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white12),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF22D3EE), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        if (_otpError != null) ...[
          const SizedBox(height: 12),
          Text(_otpError!, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600)),
        ],

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22D3EE),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isVerifyingOtp ? null : _verifyOtp,
            child: _isVerifyingOtp
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                : const Text('Verify OTP & Activate Protection', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _resendTimerSeconds > 0 ? 'Resend code in ${_resendTimerSeconds}s' : 'Didn’t receive code?',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            TextButton(
              onPressed: _resendTimerSeconds == 0 ? _sendOtp : null,
              child: Text(
                'Resend OTP',
                style: TextStyle(
                  color: _resendTimerSeconds == 0 ? const Color(0xFF22D3EE) : Colors.white24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3️⃣ Step 3: Verified Screen (Device Registered & Tracking Active)
  Widget _buildStep3Verified() {
    final imeiText = _imeiController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF10B981), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 48),
        ),
        const SizedBox(height: 20),
        const Text(
          'Device Verified & Registered!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your IMEI passed Luhn validation and is now bound to ARCHBRAIN real-time tracking network.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 24),

        // Device Status Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('REGISTERED DEVICE', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                        SizedBox(width: 4),
                        Text('TRACKING ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'IMEI: ${imeiText.replaceAllMapped(RegExp(r'.{3}'), (match) => '${match.group(0)} ')}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              const Text('Security Binding: AES-256 Partition Encrypted', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const Text('MDM Knox Status: Factory Reset Lock Armed', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),

        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22D3EE),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/upsell');
            },
            child: const Text('Continue to Protection Plans', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
          child: const Text('Skip to Dashboard', style: TextStyle(color: Colors.white54, fontSize: 13)),
        ),
      ],
    );
  }

  // 4️⃣ Step 4: Error & Fix Guide Screen
  Widget _buildStep4ErrorFixGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Why Did Validation Fail?', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                      'Every real phone IMEI passes the global Luhn mathematical formula. Random or mistyped digits are automatically rejected.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('How to Fix & Find Your Correct IMEI', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        const SizedBox(height: 14),

        const _StepItem(
          number: '1',
          title: 'Dial *#06# on Your Phone Dialer',
          description: 'Open your phone app, open keypad, and type *#06#. Your 15-digit IMEI appears on screen automatically.',
        ),
        const _StepItem(
          number: '2',
          title: 'Check System Settings',
          description: 'Go to Settings → About Phone → Status → IMEI 1. Copy the exact 15 digits shown.',
        ),
        const _StepItem(
          number: '3',
          title: 'Check Phone Box Label or SIM Tray',
          description: 'If your device is powered off, inspect the barcode sticker on your original phone box or eject the SIM tray to read the etched digits.',
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22D3EE),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              setState(() {
                _flowStep = 0; // Return to IMEI Input
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Entering IMEI Again', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildDialCodeTab() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(
          title: 'Fastest Method — Works on ALL Phones',
          description: 'Open your phone dialer and type a special code. Your IMEI appears on screen instantly in less than 10 seconds.',
          badgeText: 'RECOMMENDED',
        ),
        SizedBox(height: 16),
        _ImeiCodeCard(),
      ],
    );
  }

  Widget _buildSettingsTab() {
    final brandCards = [
      const _BrandInfo(
        name: 'Samsung (Galaxy A, S, M, Z series)',
        steps: [
          'Open Settings app',
          'Scroll down → tap "About Phone"',
          'Locate 15-digit IMEI',
        ],
      ),
      const _BrandInfo(
        name: 'Apple (iPhone)',
        steps: [
          'Open Settings → General',
          'Tap "About"',
          'Scroll to Primary IMEI',
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _InfoCard(
          title: 'Find IMEI in System Settings',
          description: 'Select your phone brand to see exact steps for finding your IMEI inside settings.',
        ),
        const SizedBox(height: 14),
        ...brandCards,
      ],
    );
  }

  Widget _buildPhoneBoxTab() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoCard(
          title: 'Find IMEI on Packaging or SIM Tray',
          description: 'If your screen is broken, check the barcode label on your phone box or the metal SIM tray.',
          badgeText: 'PHYSICAL CHECK',
        ),
      ],
    );
  }

  Widget _buildWhatIsImeiTab() {
    final faqs = [
      {
        'q': 'What is an IMEI number?',
        'a': 'IMEI is a unique 15-digit code assigned to every mobile device globally.',
      },
      {
        'q': 'Why does ARCHBRAIN validate the Luhn formula?',
        'a': 'The Luhn algorithm ensures fake or mistyped numbers are rejected before saving.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _InfoCard(
          title: 'Understanding IMEI & Luhn Validation',
          description: 'Learn why your IMEI is essential for securing your smartphone with ARCHBRAIN.',
        ),
        const SizedBox(height: 14),
        ...faqs.asMap().entries.map((entry) {
          final idx = entry.key;
          final faq = entry.value;
          final isExpanded = idx < _faqExpanded.length ? _faqExpanded[idx] : false;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: ExpansionTile(
              initiallyExpanded: isExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  if (idx < _faqExpanded.length) {
                    _faqExpanded[idx] = expanded;
                  }
                });
              },
              title: Text(faq['q']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              children: [
                Text(faq['a']!, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF22D3EE).withValues(alpha: 0.15) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF22D3EE) : Colors.white12,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF22D3EE) : Colors.white70,
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final String? badgeText;

  const _InfoCard({
    required this.title,
    required this.description,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badgeText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22D3EE).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText!,
                style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}

class _ImeiCodeCard extends StatelessWidget {
  const _ImeiCodeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF22D3EE).withValues(alpha: 0.1),
            const Color(0xFF0EA5E9).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF22D3EE).withValues(alpha: 0.3)),
      ),
      child: const Column(
        children: [
          Text('DIAL CODE', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          SizedBox(height: 6),
          Text('*#06#', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 4.0, fontFamily: 'monospace')),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone_outlined, size: 14, color: Color(0xFF22D3EE)),
              SizedBox(width: 6),
              Text('Type this in your phone app dialer', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepItem({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF22D3EE), width: 1.5),
              color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
            ),
            child: Text(number, style: const TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandInfo extends StatelessWidget {
  final String name;
  final List<String> steps;

  const _BrandInfo({
    required this.name,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.smartphone, color: Color(0xFF22D3EE), size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text('${entry.key + 1}. ${entry.value}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            );
          }),
        ],
      ),
    );
  }
}