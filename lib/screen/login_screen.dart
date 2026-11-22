import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'insurance_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _primary = Color(0xFF0A6C56);
  static const _surface = Color(0xFFF3F5FA);

  bool _isPhone = true;
  bool _loading = false;
  final _contactCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _contactCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _msg(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  void _goNext([String? welcome]) {
    if (!mounted) return;
    if (welcome != null) _msg(welcome);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const InsuranceScreen()),
    );
  }

  // Signing In with Phone or Email
  Future<void> _signIn() async {
    final contact = _contactCtrl.text.trim();
    if (contact.isEmpty) {
      return _msg('Enter your ${_isPhone ? 'phone number' : 'email'}.');
    }
    setState(() => _loading = true);

    try {
      if (_isPhone) {
        final phone = '+250${contact.replaceAll(' ', '')}';
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (cred) async {
            await FirebaseAuth.instance.signInWithCredential(cred);
            _goNext('Welcome back to MediMatch!');
          },
          verificationFailed: (e) {
            if (mounted) setState(() => _loading = false);
            _msg('Phone Auth Error: ${e.message}');
          },
          codeSent: (verId, _) {
            if (mounted) setState(() => _loading = false);
            _showOtp(verId);
          },
          codeAutoRetrievalTimeout: (_) {},
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: contact,
          password: _passCtrl.text.trim(),
        );
        _goNext('Welcome back to MediMatch!');
      }
    } on FirebaseAuthException catch (e) {
      _msg(e.message ?? 'Sign-in failed.');
    } finally {
      if (!_isPhone && mounted) setState(() => _loading = false);
    }
  }

  // Signing In with Google Account
  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final webId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
      await GoogleSignIn.instance.initialize(serverClientId: webId);
      final user = await GoogleSignIn.instance.authenticate();
      final cred = GoogleAuthProvider.credential(
        idToken: user.authentication.idToken,
      );
      final res = await FirebaseAuth.instance.signInWithCredential(cred);

      FirebaseFirestore.instance
          .collection('users')
          .doc(res.user!.uid)
          .set({
            'fullName': res.user!.displayName ?? user.displayName ?? '',
            'email': res.user!.email ?? user.email,
            'lastLogin': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true))
          .catchError((e) => debugPrint('Firestore sync: $e'));

      _goNext('Signed in with Google!');
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _msg('Google Sign-In failed: ${e.description}');
      }
    } catch (e) {
      _msg('Google Sign-In error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // OTP Dialog for Phone Verification
  void _showOtp(String verId) {
    final otpCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Enter 6-Digit SMS Code'),
        content: TextField(
          controller: otpCtrl,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _loading = true);
              try {
                final cred = PhoneAuthProvider.credential(
                  verificationId: verId,
                  smsCode: otpCtrl.text.trim(),
                );
                await FirebaseAuth.instance.signInWithCredential(cred);
                _goNext('Welcome back to MediMatch!');
              } catch (_) {
                if (mounted) setState(() => _loading = false);
                _msg('Invalid OTP code.');
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  // Main Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.add_location_alt_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF5EC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, size: 13, color: _primary),
                    SizedBox(width: 5),
                    Text(
                      'SECURE HEALTHCARE PORTAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Welcome Header
              const SizedBox(height: 12),
              const Text(
                'Welcome to MediMatch',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF151C2C),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Access your saved health insurance, emergency contacts, and verified medical providers across Rwanda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
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
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _tab(
                            'Phone (+250)',
                            Icons.phone_outlined,
                            _isPhone,
                            () => setState(() => _isPhone = true),
                          ),
                          _tab(
                            'Email',
                            Icons.mail_outline,
                            !_isPhone,
                            () => setState(() => _isPhone = false),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isPhone ? 'Mobile Phone Number' : 'Email Address',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_isPhone)
                          const Text(
                            'MTN / Airtel',
                            style: TextStyle(
                              fontSize: 11,
                              color: _primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _field(
                      ctrl: _contactCtrl,
                      hint: _isPhone ? '788 123 456' : 'name@gmail.com',
                      prefix: _isPhone ? '🇷🇼 +250  ' : null,
                      icon: _isPhone ? null : Icons.alternate_email,
                      type: _isPhone
                          ? TextInputType.phone
                          : TextInputType.emailAddress,
                    ),
                    if (!_isPhone) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _field(
                        ctrl: _passCtrl,
                        hint: 'Enter your password',
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),
                    ] else
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(
                          'Ideal for seamless Mobile Money (MoMo) coverage billing.',
                          style: TextStyle(fontSize: 11, color: Colors.black45),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _loading ? null : _signIn,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    // Signing In using Google Account UI
                    const SizedBox(height: 14),
                    const Center(
                      child: Text(
                        'OR SIGN IN WITH',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _surface,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _loading ? null : _signInWithGoogle,
                        icon: const Icon(
                          Icons.g_mobiledata,
                          color: Colors.red,
                          size: 26,
                        ),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Continue As Guest
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: _loading
                            ? null
                            : () => _goNext('Exploring as Guest'),
                        icon: const Icon(
                          Icons.explore_outlined,
                          size: 17,
                          color: _primary,
                        ),
                        label: const Text(
                          'Continue as Guest Explorer',
                          style: TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Color(0xFFDDF5EC),
                      child: Icon(Icons.lock, size: 15, color: _primary),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Privacy Guaranteed',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your health records, RSSB/RAMA affiliations, and travel insurance credentials stay strictly encrypted on your device.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "New to Rwanda's health system? ",
                    style: TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    ),
                    child: const Text(
                      'Create account',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_pharmacy_outlined,
                    size: 13,
                    color: Colors.black45,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Find 24/7 Pharmacy',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('•', style: TextStyle(color: Colors.black26)),
                  ),
                  Icon(Icons.emergency, size: 13, color: Colors.red),
                  SizedBox(width: 4),
                  Text(
                    'SOS 112 (Ambulance)',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab Widget for Phone/Email Selection
  Widget _tab(String label, IconData icon, bool active, VoidCallback onTap) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: active
                  ? [const BoxShadow(color: Colors.black12, blurRadius: 3)]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 15, color: active ? _primary : Colors.black54),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? _primary : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // Input Field Widget
  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    IconData? icon,
    String? prefix,
    bool obscure = false,
    TextInputType? type,
  }) => TextField(
    controller: ctrl,
    obscureText: obscure,
    keyboardType: type,
    style: const TextStyle(fontSize: 13.5),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
      prefixIcon: icon != null
          ? Icon(icon, size: 18, color: Colors.black45)
          : null,
      prefixText: prefix,
      prefixStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontSize: 13,
      ),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
