import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _signFirstNameController = TextEditingController();
  final _signLastNameController = TextEditingController();
  final _signEmailController = TextEditingController();
  final _signPhoneController = TextEditingController();
  final _signPasswordController = TextEditingController();
  final _signConfirmController = TextEditingController();

  bool _isLoginMode = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _showLoginPassword = false;
  bool _showSignPassword = false;
  bool _showSignConfirm = false;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your password';
    if (value.trim().length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (value.trim().length < 2) return 'Enter a valid name';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your phone number';
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 8) return 'Enter a valid phone number';
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final success = await _auth.login(
      _loginEmailController.text.trim(),
      _loginPasswordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/consent');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please check your credentials.')),
      );
    }
  }

  Future<void> _handleSignUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;
    if (_signPasswordController.text.trim() != _signConfirmController.text.trim()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final success = await _auth.register(
      '${_signFirstNameController.text.trim()} ${_signLastNameController.text.trim()}',
      _signEmailController.text.trim(),
      _signPhoneController.text.trim(),
      _signPasswordController.text.trim(),
    );

    final signUpSuccess = success;
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (signUpSuccess) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_full_name', '${_signFirstNameController.text.trim()} ${_signLastNameController.text.trim()}');
      await prefs.setString('profile_email', _signEmailController.text.trim());
      await prefs.setString('profile_phone', _signPhoneController.text.trim());

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/consent');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up failed. Please try again.')),
      );
    }
  }

  InputDecoration _inputDecoration({required String label, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF101827),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFEF476F)),
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label: label, suffixIcon: suffixIcon),
      validator: validator,
    );
  }

  Widget _buildSection({required String title, required List<Widget> fields, required String buttonText, required VoidCallback onButtonTap, Widget? extra}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1320),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF1F2A44)),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.2), blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Access your account with email and password.', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 24),
          ...fields,
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : onButtonTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF476F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  : Text(buttonText),
            ),
          ),
          if (extra != null) ...[
            const SizedBox(height: 16),
            extra,
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginFields = [
      _buildTextField(
        label: 'Username',
        controller: _loginEmailController,
        validator: _validateEmail,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Password',
        controller: _loginPasswordController,
        validator: _validatePassword,
        obscureText: !_showLoginPassword,
        suffixIcon: IconButton(
          splashRadius: 20,
          icon: Icon(_showLoginPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
          onPressed: () => setState(() => _showLoginPassword = !_showLoginPassword),
        ),
      ),
    ];

    final signUpFields = [
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              label: 'First Name',
              controller: _signFirstNameController,
              validator: _validateName,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTextField(
              label: 'Last Name',
              controller: _signLastNameController,
              validator: _validateName,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Email',
        controller: _signEmailController,
        validator: _validateEmail,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Phone',
        controller: _signPhoneController,
        validator: _validatePhone,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Password',
        controller: _signPasswordController,
        validator: _validatePassword,
        obscureText: !_showSignPassword,
        suffixIcon: IconButton(
          splashRadius: 20,
          icon: Icon(_showSignPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
          onPressed: () => setState(() => _showSignPassword = !_showSignPassword),
        ),
      ),
      const SizedBox(height: 16),
      _buildTextField(
        label: 'Confirm Password',
        controller: _signConfirmController,
        validator: _validatePassword,
        obscureText: !_showSignConfirm,
        suffixIcon: IconButton(
          splashRadius: 20,
          icon: Icon(_showSignConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
          onPressed: () => setState(() => _showSignConfirm = !_showSignConfirm),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF090E1A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildModeTab('Log In', true),
                    _buildModeTab('Sign Up', false),
                  ],
                ),
                const SizedBox(height: 24),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: Form(
                    key: _loginFormKey,
                    child: _buildSection(
                      title: 'Log In',
                      fields: [
                        ...loginFields,
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              activeColor: const Color(0xFFEF476F),
                              onChanged: (value) => setState(() => _rememberMe = value ?? false),
                            ),
                            const Expanded(child: Text('Remember me', style: TextStyle(color: Colors.white70))),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Forgot Password', style: TextStyle(color: Color(0xFFEF476F))),
                            ),
                          ],
                        ),
                      ],
                      buttonText: 'Log in',
                      onButtonTap: _handleLogin,
                      extra: Column(
                        children: [
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialIcon(Icons.facebook, Colors.blueAccent),
                              const SizedBox(width: 12),
                              _socialIcon(Icons.share, Colors.lightBlue),
                              const SizedBox(width: 12),
                              _socialIcon(Icons.g_mobiledata, Colors.redAccent),
                              const SizedBox(width: 12),
                              _socialIcon(Icons.camera_alt, Colors.pinkAccent),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => setState(() => _isLoginMode = false),
                            child: const Text('Don\'t have an account? Sign up', style: TextStyle(color: Color(0xFFEF476F))),
                          ),
                        ],
                      ),
                    ),
                  ),
                  secondChild: Form(
                    key: _signUpFormKey,
                    child: _buildSection(
                      title: 'Sign Up',
                      fields: signUpFields,
                      buttonText: 'Sign up',
                      onButtonTap: _handleSignUp,
                      extra: TextButton(
                        onPressed: () => setState(() => _isLoginMode = true),
                        child: const Text('Already have an account? Sign in', style: TextStyle(color: Color(0xFFEF476F))),
                      ),
                    ),
                  ),
                  crossFadeState: _isLoginMode ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab(String label, bool loginTab) {
    final active = _isLoginMode == loginTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLoginMode = loginTab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF151F3D) : const Color(0xFF0A1225),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: active ? const Color(0xFFEF476F) : const Color(0xFF1F2A44)),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
