import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const _primaryColor = Color(0xFF0A6C56);
  static const _surfaceColor = Color(0xFFF3F5FA);

  bool _isPhoneMode = true;
  bool _isLoading = false;

  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController(); // Phone or Email
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final name = _nameCtrl.text.trim();
    final contact = _contactCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (name.isEmpty || contact.isEmpty || password.length < 6) {
      _showMsg('Enter full name, contact, and a 6+ char password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Use a dummy email for phone-based registration
      final authEmail = _isPhoneMode
          ? '${contact.replaceAll(' ', '')}@medimatch.rw'
          : contact;

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: authEmail,
        password: password,
      );

      // Save user profile in Firestore
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'fullName': name,
        'phone': _isPhoneMode ? '+250$contact' : '',
        'email': _isPhoneMode ? '' : contact,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) _showMsg('Account created! Welcome to MediMatch.');
    } on FirebaseAuthException catch (e) {
      _showMsg(e.message ?? 'Registration failed.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMsg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            children: [
              // Top Brand Icon & Badge
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: _primaryColor.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Icon(Icons.add_location_alt_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFFDDF5EC), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, size: 13, color: _primaryColor),
                    SizedBox(width: 5),
                    Text('SECURE HEALTHCARE PORTAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _primaryColor, letterSpacing: 0.5)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('Create Your Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF151C2C))),
              const SizedBox(height: 4),
              const Text(
                'Register to save your health insurance, emergency contacts, and verified providers across Rwanda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Main Form Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone vs Email Switcher
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          _modeTab('Phone (+250)', Icons.phone_outlined, _isPhoneMode, () => setState(() => _isPhoneMode = true)),
                          _modeTab('Email', Icons.mail_outline, !_isPhoneMode, () => setState(() => _isPhoneMode = false)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Full Name Field
                    const Text('Full Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    _inputField(controller: _nameCtrl, hint: 'e.g. Jean Claude Mugabo', icon: Icons.person_outline),
                    const SizedBox(height: 12),

                    // Phone or Email Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_isPhoneMode ? 'Mobile Phone Number' : 'Email Address', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        if (_isPhoneMode) const Text('MTN / Airtel', style: TextStyle(fontSize: 11, color: _primaryColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: _contactCtrl,
                      hint: _isPhoneMode ? '788 123 456' : 'name@example.com',
                      prefixText: _isPhoneMode ? '🇷🇼 +250  ' : null,
                      icon: _isPhoneMode ? null : Icons.alternate_email,
                      keyboardType: _isPhoneMode ? TextInputType.phone : TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // Password Field
                    const Text('Create Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    _inputField(controller: _passwordCtrl, hint: 'Minimum 6 characters', icon: Icons.lock_outline, obscure: true),
                    const SizedBox(height: 16),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: _isLoading ? null : _registerUser,
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Center(child: Text('OR SIGN UP WITH', style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 0.8))),
                    const SizedBox(height: 12),

                    // Google Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _surfaceColor,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () {}, // Hook GoogleAuthProvider here
                        icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 26),
                        label: const Text('Continue with Google', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Privacy Card (Matches Login Figma)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: _surfaceColor, borderRadius: BorderRadius.circular(16)),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 15, backgroundColor: Color(0xFFDDF5EC), child: Icon(Icons.lock, size: 15, color: _primaryColor)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Data Privacy Guaranteed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text(
                            'Your health records, RSSB/RAMA affiliations, and travel insurance credentials stay strictly encrypted.',
                            style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Switch to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(fontSize: 12.5, color: Colors.black54)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Navigates back to LoginScreen
                    child: const Text('Sign In', style: TextStyle(fontSize: 12.5, color: _primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeTab(String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active ? [const BoxShadow(color: Colors.black12, blurRadius: 3)] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: active ? _primaryColor : Colors.black54),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? _primaryColor : Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    String? prefixText,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, size: 18, color: Colors.black45) : null,
        prefixText: prefixText,
        prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13),
        filled: true,
        fillColor: _surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}