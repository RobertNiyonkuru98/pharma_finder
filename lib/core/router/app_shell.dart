import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pharma_finder/core/router/navigation_cubit.dart';
import 'package:pharma_finder/core/theme/app_theme.dart';
import 'package:pharma_finder/features/facilities/presentation/cubit/facilities_cubit.dart';
import 'package:pharma_finder/features/facilities/presentation/screens/facilities_search_screen.dart';
import 'package:pharma_finder/features/facilities/presentation/screens/facilities_screen.dart';
import 'package:pharma_finder/features/emergency/presentation/emergency_screen.dart';
import 'package:pharma_finder/features/profile/presentation/profile_screen.dart';
import 'package:pharma_finder/services/user_profile.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FacilitiesCubit>(create: (_) => FacilitiesCubit()..load()),
        BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
      ],
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, index) {
          final navigation = context.read<NavigationCubit>();
          return Scaffold(
            body: IndexedStack(
              index: index,
              children: [
                FacilitiesScreen(
                  onOpenSearch: () =>
                      navigation.select(NavigationCubit.searchTab),
                  onOpenProfile: () =>
                      navigation.select(NavigationCubit.profileTab),
                ),
                const FacilitiesSearchScreen(),
                EmergencyScreen(user: UserProfile.current()),
                ProfileScreen(user: UserProfile.current()),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: navigation.select,
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
          );
        },
      ),
    );
  }
}
