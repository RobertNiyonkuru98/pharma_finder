import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/facilities/presentation/cubit/facilities_cubit.dart';
import 'features/facilities/presentation/screens/facilities_screen.dart';

void main() {
  runApp(const PharmaFinderApp());
}

/// NOTE: there is deliberately no Firebase.initializeApp() yet.
///
/// That call needs firebase_options.dart, which Igihozo produces when he
/// creates the Firebase project. Calling it before then crashes on launch and
/// would break the rule that `main` always builds and runs.
class PharmaFinderApp extends StatelessWidget {
  const PharmaFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FacilitiesCubit()..load(),
      child: MaterialApp(
        title: 'PharmaFinder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: .fromSeed(seedColor: Colors.teal),
        ),
        home: const FacilitiesScreen(),
      ),
    );
  }
}
