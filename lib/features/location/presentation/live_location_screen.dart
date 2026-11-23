import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pharma_finder/core/router/app_shell.dart';
import 'package:pharma_finder/core/theme/app_theme.dart';
import 'package:pharma_finder/features/location/live_location.dart';

/// "Enable location" — mirrors InsuranceScreen layout:
/// progress header + scrollable body + bottom action button.
///
/// Requests permission on first frame, then streams live position updates
/// so the card refreshes as the user moves. Continue routes to [AppShell].
class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  bool _trackingStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startTracking();
    });
  }

  Future<void> _startTracking() async {
    if (_trackingStarted) return;
    _trackingStarted = true;
    await context.read<LocationCubit>().requestAndStreamLocation();
  }

  void _goToShell() {
    // Stop the GPS stream so it doesn't keep draining battery inside AppShell.
    // Remove this call later if a tab in AppShell needs live tracking.
    context.read<LocationCubit>().stopTracking();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<LocationCubit, LocationState>(
          builder: (context, state) {
            final isLoading =
                state is LocationLoading || state is LocationInitial;
            final isLoaded = state is LocationLoaded;
            final isError = state is LocationError;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ProgressHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    children: [
                      const Text(
                        'Enable location',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        "We use your location to find pharmacies, clinics, "
                        'and hospitals near you that accept your insurance. '
                        'You can change this later in Profile.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _LocationStatusCard(state: state),
                      if (isLoaded) ...[
                        const SizedBox(height: AppSpacing.md),
                        _LiveCoordsCard(position: state.position),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      const _PrivacyNote(),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: FilledButton(
                    onPressed: isLoading
                        ? null
                        : isLoaded
                            ? _goToShell
                            : () => context
                                .read<LocationCubit>()
                                .requestAndStreamLocation(),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isLoaded
                            ? 'Continue'
                            : isError
                                ? 'Try again'
                                : 'Allow location'),
                  ),
                ),
                if (isError)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                    ),
                    child: TextButton(
                      onPressed: _goToShell,
                      child: const Text('Continue without location'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, size: 20),
            color: AppColors.ink,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.7,
                minHeight: 6,
                backgroundColor: AppColors.lavenderDeep,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status card
// ─────────────────────────────────────────────────────────────────────────────

class _LocationStatusCard extends StatelessWidget {
  final LocationState state;

  const _LocationStatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
      final s = state;   
    if (s is LocationLoading || s is LocationInitial) {
      return const _Card(
        icon: Icons.location_searching,
        iconColor: AppColors.primary,
        iconBg: AppColors.lavender,
        title: 'Finding your location…',
        subtitle: 'Approve the system prompt to continue.',
      );
    }
    if (s is LocationLoaded) {
      return _Card(
        icon: Icons.location_on,
        iconColor: AppColors.primary,
        iconBg: AppColors.primaryTint,
        title: 'Location confirmed',
        subtitle: s.placeName,
        badge: 'Live',
      );
    }
    final message = (state as LocationError).message;
    return _Card(
      icon: Icons.location_off,
      iconColor: AppColors.muted,
      iconBg: AppColors.lavenderDeep,
      title: 'Location unavailable',
      subtitle: message,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Live coordinates card
// ─────────────────────────────────────────────────────────────────────────────

class _LiveCoordsCard extends StatelessWidget {
  final dynamic position; // geolocator Position — dynamic to avoid extra import

  const _LiveCoordsCard({required this.position});

  @override
  Widget build(BuildContext context) {
    final lat = (position.latitude as num).toStringAsFixed(5);
    final lng = (position.longitude as num).toStringAsFixed(5);
    final acc = (position.accuracy as num).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.my_location, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Live coordinates',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _kv('Latitude', lat),
          _kv('Longitude', lng),
          _kv('Accuracy', '±$acc m'),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(
                k,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ),
            Expanded(
              child: Text(
                v,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic card
// ─────────────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? badge;

  const _Card({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Privacy note
// ─────────────────────────────────────────────────────────────────────────────

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lavender,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 18, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your coordinates are used only to match you with nearby '
              'providers. They are never shared with third parties.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}