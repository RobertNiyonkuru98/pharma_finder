import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pharma_finder/core/theme/app_theme.dart';
import 'package:pharma_finder/features/facilities/presentation/cubit/facilities_cubit.dart';
import 'package:pharma_finder/features/facilities/presentation/screens/facilities_search_screen.dart';
import 'package:pharma_finder/features/facilities/presentation/screens/facilities_screen.dart';
import 'package:pharma_finder/features/emergency/presentation/emergency_screen.dart';
import 'package:pharma_finder/features/profile/presentation/profile_screen.dart';
import 'package:pharma_finder/services/user_profile.dart';

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
          children: [
            FacilitiesScreen(
              onOpenSearch: () => setState(() => _index = 1),
              onOpenProfile: () => setState(() => _index = 3),
            ),
            const FacilitiesSearchScreen(),
            EmergencyScreen(user: UserProfile.current()),
            ProfileScreen(user: UserProfile.current()),
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
