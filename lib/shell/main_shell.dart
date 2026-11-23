import 'package:flutter/material.dart';

import 'package:pharma_finder/core/theme/app_colors.dart';
import 'package:pharma_finder/features/emergency/presentation/emergency_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../services/user_profile.dart';

/// Exposes the shell's tab controller to descendants so any child screen can
/// switch tabs, e.g. `MainShellScope.of(context).value = MainShell.profileTab`.
class MainShellScope extends InheritedWidget {
  const MainShellScope({
    super.key,
    required this.tabIndex,
    required super.child,
  });

  final ValueNotifier<int> tabIndex;

  static ValueNotifier<int>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MainShellScope>()?.tabIndex;

  static ValueNotifier<int> of(BuildContext context) {
    final notifier = maybeOf(context);
    assert(notifier != null, 'No MainShellScope found above this context.');
    return notifier!;
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) =>
      tabIndex != oldWidget.tabIndex;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.user, this.initialIndex = homeTab});

  /// The signed-in account, shared by every tab.
  final UserProfile user;

  final int initialIndex;

  static const int homeTab = 0;
  static const int searchTab = 1;
  static const int sosTab = 2;
  static const int profileTab = 3;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final ValueNotifier<int> _tabIndex = ValueNotifier<int>(
    widget.initialIndex,
  );

  @override
  void dispose() {
    _tabIndex.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (_tabIndex.value != index) _tabIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return MainShellScope(
      tabIndex: _tabIndex,
      child: ValueListenableBuilder<int>(
        valueListenable: _tabIndex,
        builder: (context, index, _) {
          return Scaffold(
            body: IndexedStack(
              index: index,
              children: <Widget>[
                const _PlaceholderTab(
                  icon: Icons.storefront_rounded,
                  message: 'Pharmacies near you',
                ),
                const _PlaceholderTab(
                  icon: Icons.search_rounded,
                  message: 'Search pharmacies and hospitals',
                ),
                EmergencyScreen(user: widget.user),
                ProfileScreen(user: widget.user),
              ],
            ),
            bottomNavigationBar: _BottomNavBar(
              currentIndex: index,
              onSelect: _select,
            ),
          );
        },
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: AppShadows.softTop,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _NavItem(
                icon: currentIndex == MainShell.homeTab
                    ? Icons.home_rounded
                    : Icons.home_outlined,
                label: 'Home',
                selected: currentIndex == MainShell.homeTab,
                onTap: () => onSelect(MainShell.homeTab),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Search',
                selected: currentIndex == MainShell.searchTab,
                onTap: () => onSelect(MainShell.searchTab),
              ),
              _NavItem(
                icon: Icons.emergency_rounded,
                label: 'SOS',
                selected: currentIndex == MainShell.sosTab,
                isEmergency: true,
                onTap: () => onSelect(MainShell.sosTab),
              ),
              _NavItem(
                icon: currentIndex == MainShell.profileTab
                    ? Icons.person_rounded
                    : Icons.person_outline_rounded,
                label: 'Profile',
                selected: currentIndex == MainShell.profileTab,
                onTap: () => onSelect(MainShell.profileTab),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.isEmergency = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isEmergency;

  @override
  Widget build(BuildContext context) {
    final color = isEmergency
        ? AppColors.emergencyRed
        : (selected ? AppColors.primaryGreen : AppColors.textMuted);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 30,
                child: Center(
                  child: isEmergency
                      ? Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: AppColors.emergencyRedLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 17,
                            color: AppColors.emergencyRed,
                          ),
                        )
                      : Icon(icon, size: 24, color: color),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
