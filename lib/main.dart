import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/location/location_store.dart';
import 'core/preferences/app_preferences.dart';
import 'core/preferences/preferences_cubit.dart';
import 'core/router/app_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/location/live_location.dart';
import 'screen/onboarding_screen.dart';

Future<User?> _restoreSession() async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser != null) return auth.currentUser;

  try {
    return await auth.authStateChanges().first.timeout(
      const Duration(seconds: 3),
    );
  } catch (error) {
    debugPrint('Session restore failed: $error');
    return auth.currentUser;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (_) { }

  // Preferences are local, so they load even when Firebase is unreachable.
  final preferences = await PreferencesCubit.loadPersisted();

  try {
    await Firebase.initializeApp();

    final restored = await _restoreSession();

    // Restore the last known position before the first frame so the GPS card
    if (restored != null) {
      await LocationStore.load();
    }

    runApp(
      MediMatchApp(
        startSignedIn: restored != null,
        preferences: preferences,
      ),
    );
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
  const MediMatchApp({
    super.key,
    this.startSignedIn = false,
    this.preferences = AppPreferences.defaults,
  });

  /// True when a persisted Firebase session was restored before the first
  /// frame. Signed-in users skip onboarding and land in the app shell.
  final bool startSignedIn;

  /// Snapshot read from `shared_preferences` before the first frame.
  final AppPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PreferencesCubit>(
          create: (context) => PreferencesCubit(preferences),
        ),
        BlocProvider<LocationCubit>(
          create: (context) => LocationCubit()..loadIfPermitted(),
        ),
      ],
      child: BlocBuilder<PreferencesCubit, AppPreferences>(
        builder: (context, preferences) {
          return MaterialApp(
            title: 'MediMatch',
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(),
            darkTheme: buildDarkAppTheme(),
            themeMode: preferences.themeMode,
            home: startSignedIn ? const AppShell() : const OnboardingScreen(),
          );
        },
      ),
    );
  }
}
