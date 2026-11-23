import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pharma_finder/core/theme/app_theme.dart';

/// Emergency / SOS tab.
///
/// Numbers are Rwanda's national services, as shown in the Figma design:
/// 112 ambulance & police, 111 fire & rescue, 3512 Isange One Stop Centre.
/// Verify against an official Rwandan government source before citing them in
/// the report — the brief treats an uncited claim as a citation mismatch.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  static const _services = [
    _Service(
      number: '112',
      label: 'Ambulance & Police',
      detail: 'Rwanda National Police • SAMU dispatch • 24/7',
      isPrimary: true,
    ),
    _Service(
      number: '111',
      label: 'Fire & Rescue',
      detail: 'Urban fire, extraction and hazard response',
    ),
    _Service(
      number: '3512',
      label: 'Isange One Stop Centre',
      detail: 'GBV and medical rapid care hotline',
    ),
  ];

  Future<void> _call(BuildContext context, String number) async {
    final uri = Uri.parse('tel:$number');
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open the dialer. Dial $number manually.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.dangerTint,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RWANDA SAMU DISPATCH',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'National Medical Ambulance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Direct line to Kigali central dispatch, 24 hours.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: () => _call(context, '112'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                  ),
                  icon: const Icon(Icons.call),
                  label: const Text('CALL 112 — AMBULANCE'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Emergency Services Directory',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final s in _services) _ServiceCard(service: s, onCall: _call),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Emergency trauma care is generally provided before billing '
                    'is settled. Confirm current policy with the facility.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.ink,
                    ),
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

class _Service {
  final String number;
  final String label;
  final String detail;
  final bool isPrimary;

  const _Service({
    required this.number,
    required this.label,
    required this.detail,
    this.isPrimary = false,
  });
}

class _ServiceCard extends StatelessWidget {
  final _Service service;
  final Future<void> Function(BuildContext, String) onCall;

  const _ServiceCard({required this.service, required this.onCall});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: AppColors.dangerTint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              service.number,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
          ),
        ),
        title: Text(
          service.label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          service.detail,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        trailing: IconButton(
          onPressed: () => onCall(context, service.number),
          icon: const Icon(Icons.call, color: AppColors.primary),
        ),
      ),
    );
  }
}
