import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final String? deviceId;

  const ProfileScreen({super.key, this.deviceId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _imeiController;

  String _fullName = 'Your Name';
  String _email = 'your@email.com';
  String _phone = 'Phone number';
  String _imei = 'No IMEI saved';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _imeiController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _imeiController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _fullName = prefs.getString('profile_full_name') ?? 'Your Name';
      _email = prefs.getString('profile_email') ?? 'your@email.com';
      _phone = prefs.getString('profile_phone') ?? 'Phone number';
      _imei = prefs.getString('profile_imei') ?? 'No IMEI saved';
      _fullNameController.text = _fullName;
      _emailController.text = _email;
      _phoneController.text = _phone;
      _imeiController.text = _imei;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_full_name', _fullNameController.text.trim());
    await prefs.setString('profile_email', _emailController.text.trim());
    await prefs.setString('profile_phone', _phoneController.text.trim());

    if (!mounted) return;
    setState(() {
      _fullName = _fullNameController.text.trim();
      _email = _emailController.text.trim();
      _phone = _phoneController.text.trim();
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final initials = _fullName.trim().isNotEmpty ? _fullName.trim().split(RegExp(r'\s+')).take(2).map((e) => e[0]).join().toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF22D3EE), width: 1),
                    ),
                    child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF22D3EE).withValues(alpha: 0.1), const Color(0xFF0EA5E9).withValues(alpha: 0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF0EA5E9)])),
                      child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(height: 12),
                    Text(_fullName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Text('✓ ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('IMEI NUMBER', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                child: Text(_imei, style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 14, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              const Text('PROFILE DETAILS', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Full name'),
                      validator: (value) => (value == null || value.trim().length < 2) ? 'Enter your full name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Email'),
                      validator: (value) => (value == null || value.trim().isEmpty || !value.contains('@')) ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Phone'),
                      validator: (value) => (value == null || value.trim().length < 7) ? 'Enter a valid phone number' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imeiController,
                      style: const TextStyle(color: Colors.white70),
                      enabled: false,
                      decoration: _buildInputDecoration('Locked IMEI').copyWith(fillColor: const Color(0xFF111827), filled: true),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22D3EE), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: _isSaving ? null : _saveProfile,
                        child: _isSaving ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.black) : const Text('Save profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22D3EE), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () => Navigator.pushNamed(context, '/live-location'),
                  child: const Text('View Live Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF22D3EE)), borderRadius: BorderRadius.circular(12)),
    );
  }
}
