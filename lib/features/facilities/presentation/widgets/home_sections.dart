import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pharma_finder/core/theme/app_theme.dart';
import 'package:pharma_finder/features/facilities/domain/entities/facility.dart';
import 'package:pharma_finder/features/facilities/presentation/cubit/facilities_state.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.medical_services_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MediMatch',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'HOME',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.ink,
          ),
        ),
        IconButton(
          onPressed: onProfileTap,
          icon: const Icon(Icons.account_circle_outlined, color: AppColors.ink),
        ),
      ],
    );
  }
}

class ActivePolicyCard extends StatelessWidget {
  const ActivePolicyCard({
    super.key,
    required this.planName,
    required this.onChangeTap,
  });

  final String planName;
  final VoidCallback onChangeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACTIVE POLICY',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  planName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Verified coverage',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(onPressed: onChangeTap, child: const Text('Change')),
        ],
      ),
    );
  }
}

class QuickFiltersRow extends StatelessWidget {
  const QuickFiltersRow({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<FacilityQuickFilter> selected;
  final ValueChanged<FacilityQuickFilter> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(
          label: 'Pharmacies',
          icon: Icons.local_pharmacy_outlined,
          selected: selected.contains(FacilityQuickFilter.pharmacies),
          onTap: () => onToggle(FacilityQuickFilter.pharmacies),
        ),
        _chip(
          label: 'Hospitals',
          icon: Icons.local_hospital_outlined,
          selected: selected.contains(FacilityQuickFilter.hospitals),
          onTap: () => onToggle(FacilityQuickFilter.hospitals),
        ),
        _chip(
          label: 'Open Now',
          icon: Icons.schedule_rounded,
          selected: selected.contains(FacilityQuickFilter.openNow),
          onTap: () => onToggle(FacilityQuickFilter.openNow),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? Colors.white : AppColors.muted,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      label: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      showCheckmark: false,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
    );
  }
}

class CareMapCard extends StatelessWidget {
  const CareMapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: const [
                Icon(Icons.map_rounded, size: 36, color: AppColors.primary),
                Positioned(
                  top: 18,
                  right: 18,
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interactive Care Map',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Explore nearby providers and coverage-friendly locations.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              minimumSize: const Size(76, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Explore'),
          ),
        ],
      ),
    );
  }
}

class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.facility,
    required this.onViewDetails,
  });

  final Facility facility;
  final VoidCallback onViewDetails;

  bool get _hasValidPhone {
    final phone = facility.phone?.trim() ?? '';
    return phone.isNotEmpty && RegExp(r'^[+0-9][0-9 ]{6,}$').hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    final matched = facility.acceptedPlans.any(
      (plan) =>
          plan.toLowerCase().contains('rssb') ||
          plan.toLowerCase().contains('rama'),
    );
    final typeLabel =
        facility.type[0].toUpperCase() + facility.type.substring(1);

    return Container(
      width: 300,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 112,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primaryTintAlt,
            ),
            child: const Center(
              child: Icon(
                Icons.local_hospital_rounded,
                color: AppColors.primary,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  facility.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (matched)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'RSSB Matched',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              Text(
                typeLabel,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              Text(
                facility.area,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              if (facility.rating != null)
                Text(
                  '★ ${facility.rating!.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              if (facility.distanceKm != null)
                Text(
                  '${facility.distanceKm!.toStringAsFixed(1)} km',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            facility.openingHours,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Accepted: ${facility.acceptedPlans.isEmpty ? 'Not specified' : facility.acceptedPlans.join(', ')}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          if (facility.languages.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Languages: ${facility.languages.join(', ')}',
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _hasValidPhone
                    ? () => _dial(context, facility.phone!.trim())
                    : null,
                icon: const Icon(Icons.phone_rounded, size: 16),
                label: const Text('Call'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: onViewDetails,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _dial(BuildContext context, String phone) async {
    final launched = await launchUrl(
      Uri.parse('tel:$phone'),
      mode: LaunchMode.externalApplication,
    );
    if (launched || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open dialer on this device.')),
    );
  }
}

class EmergencyAssistanceBanner extends StatelessWidget {
  const EmergencyAssistanceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.emergency_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Urgent Assistance?',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Call Rwanda emergency response now.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => _call112(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.danger,
              minimumSize: const Size(90, 38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Call 112'),
          ),
        ],
      ),
    );
  }

  Future<void> _call112(BuildContext context) async {
    final launched = await launchUrl(
      Uri.parse('tel:112'),
      mode: LaunchMode.externalApplication,
    );
    if (launched || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not place an emergency call.')),
    );
  }
}
