import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pharma_finder/core/theme/app_theme.dart';
import 'package:pharma_finder/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:pharma_finder/features/facilities/presentation/cubit/facilities_cubit.dart';
import 'package:pharma_finder/features/facilities/presentation/screens/facilities_search_screen.dart';
import 'package:pharma_finder/features/facilities/presentation/screens/facilities_screen.dart';
import 'package:pharma_finder/features/profile/presentation/screens/profile_screen.dart';

/// The four-tab frame every main screen mounts inside.
///
/// [FacilitiesCubit] is provided here, above the tabs, so Home and Search share
/// one instance — search on one tab is visible on the other, which is what a
/// user expects and what a single-Cubit-per-feature design gives you.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FacilitiesCubit()..load(),
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [
            FacilitiesScreen(),
            FacilitiesSearchScreen(),
            EmergencyScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryTint,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search, color: AppColors.primary),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.emergency_outlined, color: AppColors.danger),
              selectedIcon: Icon(Icons.emergency, color: AppColors.danger),
              label: 'SOS',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
