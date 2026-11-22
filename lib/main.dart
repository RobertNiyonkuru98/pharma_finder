import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'location/live_location.dart';
import 'screen/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // On Android the google-services gradle plugin reads
    // android/app/google-services.json at build time, so no options are passed
    // here. This replaces the previous dotenv indirection, which crashed
    // whenever .env was absent (it is gitignored, so every fresh clone lacked it).
    await Firebase.initializeApp();
    runApp(const MediMatchApp());
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    runApp(FirebaseErrorApp(message: e.toString()));
  }
}

/// Shown instead of an endless spinner when Firebase cannot initialise.
/// An infinite splash screen looks like a broken app in a demo.
class FirebaseErrorApp extends StatelessWidget {
  final String message;

  const FirebaseErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Color(0xFFCE5150)),
              const SizedBox(height: 16),
              const Text(
                'Could not connect to Firebase',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class MediMatchApp extends StatelessWidget {
  const MediMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationCubit()..getCurrentLocation(),
      child: MaterialApp(
        title: 'MediMatch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF016960)),
          useMaterial3: true,
        ),
        home: const OnboardingScreen(),
      ),
    );
  }
}
