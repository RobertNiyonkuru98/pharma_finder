import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pharma_finder/core/theme/app_theme.dart';
import 'package:pharma_finder/features/facilities/domain/entities/facility.dart';
import 'package:pharma_finder/features/facilities/presentation/cubit/facilities_cubit.dart';
import 'package:pharma_finder/features/facilities/presentation/cubit/facilities_state.dart';

class FacilitiesSearchScreen extends StatefulWidget {
  const FacilitiesSearchScreen({super.key});

  @override
  State<FacilitiesSearchScreen> createState() => _FacilitiesSearchScreenState();
}

class _FacilitiesSearchScreenState extends State<FacilitiesSearchScreen> {
  static const _insuranceOptions = <_InsuranceOption>[
    _InsuranceOption('rssb', 'RSSB (RAMA)'),
    _InsuranceOption('mmi', 'MMI (Military)'),
    _InsuranceOption('britam', 'Britam International'),
    _InsuranceOption('sanlam', 'Sanlam'),
    _InsuranceOption('cash', 'Cash / MoMo Only'),
  ];

  static const _specificNeeds = <_NeedOption>[
    _NeedOption(SpecificNeedFilter.prescriptionRefill, 'Prescription Refill'),
    _NeedOption(SpecificNeedFilter.overTheCounter, 'Over-the-counter'),
    _NeedOption(SpecificNeedFilter.maternalCare, 'Maternal Care'),
    _NeedOption(SpecificNeedFilter.emergencyTriage, 'Emergency Triage'),
  ];

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FacilitiesCubit>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<FacilitiesCubit, FacilitiesState>(
          listener: (context, state) {
            if (state is! FacilitiesLoaded) return;
            if (_searchController.text == state.query) return;
            _searchController.value = TextEditingValue(
              text: state.query,
              selection: TextSelection.collapsed(offset: state.query.length),
            );
          },
          builder: (context, state) {
            final loaded = state is FacilitiesLoaded ? state : null;
            final resultCount = loaded?.facilities.length ?? 0;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                    children: [
                      _Header(onProfileTap: () {}, onNotificationTap: () {}),
                      const SizedBox(height: 14),
                      _SearchField(
                        controller: _searchController,
                        onChanged: cubit.search,
                        onClear: cubit.clearSearch,
                        onMicTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Voice search is not available yet in this build.',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _SectionLabel(
                        icon: Icons.grid_view_rounded,
                        title: 'Category',
                      ),
                      const SizedBox(height: 8),
                      _CategoryRow(
                        selected: loaded?.category,
                        onSelect: cubit.setCategory,
                      ),
                      const SizedBox(height: 10),
                      _MatchedInfoRow(
                        matchesCount: resultCount,
                        radiusKm:
                            loaded?.distanceRadiusFilter.kilometers ??
                            DistanceRadiusFilter.fiveKm.kilometers,
                      ),
                      const SizedBox(height: 14),
                      const _SectionLabel(
                        icon: Icons.shield_outlined,
                        title: 'Accepted Insurance',
                        trailing: 'Multi-select enabled',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _insuranceOptions.map((option) {
                          final selected =
                              loaded?.selectedInsurancePlanIds.contains(
                                option.id,
                              ) ??
                              false;
                          return _SelectableChip(
                            label: option.label,
                            selected: selected,
                            onTap: () => cubit.toggleInsurancePlan(option.id),
                            selectedIcon: Icons.check_rounded,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      _SectionLabel(
                        icon: Icons.access_time_rounded,
                        title: 'Operating Hours',
                        trailing: 'Live verified',
                        trailingColor: AppColors.primary,
                      ),
                      const SizedBox(height: 8),
                      _HoursSegment(
                        selected: loaded?.operatingHoursFilter,
                        onSelect: cubit.setOperatingHoursFilter,
                      ),
                      const SizedBox(height: 16),
                      _SectionLabel(
                        icon: Icons.my_location_rounded,
                        title: 'Distance Radius',
                        trailing:
                            'Within ${loaded?.distanceRadiusFilter.kilometers ?? 5} km',
                        trailingColor: AppColors.primaryDark,
                      ),
                      const SizedBox(height: 8),
                      _DistanceRow(
                        selected: loaded?.distanceRadiusFilter,
                        onSelect: cubit.setDistanceRadiusFilter,
                      ),
                      const SizedBox(height: 16),
                      const _SectionLabel(
                        icon: Icons.medical_services_outlined,
                        title: 'Specific Needs',
                        trailing: 'Instant filter',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _specificNeeds.map((item) {
                          final selected =
                              loaded?.selectedNeeds.contains(item.need) ??
                              false;
                          return _SelectableChip(
                            label: item.label,
                            selected: selected,
                            onTap: () => cubit.toggleSpecificNeed(item.need),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      _ResultsSection(
                        state: state,
                        onRetry: cubit.load,
                        onDirections: (facility) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Directions for ${facility.name} are not connected yet.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                _BottomActionBar(
                  resultCount: resultCount,
                  onClear: cubit.clearFilters,
                  onShowResults: () {
                    if (resultCount == 0) return;
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onProfileTap, required this.onNotificationTap});

  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEDIMATCH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Search Directory',
                style: TextStyle(
                  fontSize: 32 / 2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotificationTap,
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: onProfileTap,
          borderRadius: BorderRadius.circular(99),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.onMicTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onMicTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search facilities by name or location',
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.muted),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  controller.clear();
                  onClear();
                },
                icon: const Icon(Icons.close_rounded, color: AppColors.muted),
              ),
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: onMicTap,
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryTint,
                ),
                child: const Icon(
                  Icons.mic_none_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.icon,
    required this.title,
    this.trailing,
    this.trailingColor = AppColors.muted,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryDark),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30 / 2,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
              fontSize: 12,
              color: trailingColor,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.selected, required this.onSelect});

  final FacilityCategoryFilter? selected;
  final ValueChanged<FacilityCategoryFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final current = selected ?? FacilityCategoryFilter.allCare;
    return Row(
      children: [
        Expanded(
          child: _SelectableChip(
            label: 'All Care',
            selected: current == FacilityCategoryFilter.allCare,
            onTap: () => onSelect(FacilityCategoryFilter.allCare),
            fullWidth: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SelectableChip(
            label: 'Pharmacies',
            selected: current == FacilityCategoryFilter.pharmacies,
            onTap: () => onSelect(FacilityCategoryFilter.pharmacies),
            fullWidth: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SelectableChip(
            label: 'Hospitals',
            selected: current == FacilityCategoryFilter.hospitals,
            onTap: () => onSelect(FacilityCategoryFilter.hospitals),
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}

class _MatchedInfoRow extends StatelessWidget {
  const _MatchedInfoRow({required this.matchesCount, required this.radiusKm});

  final int matchesCount;
  final int radiusKm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.primaryTintAlt,
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$matchesCount verified matches near Kigali',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'Within $radiusKm km',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _HoursSegment extends StatelessWidget {
  const _HoursSegment({required this.selected, required this.onSelect});

  final OperatingHoursFilter? selected;
  final ValueChanged<OperatingHoursFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final current = selected ?? OperatingHoursFilter.anyTime;

    Widget item(String text, OperatingHoursFilter value) {
      final active = current == value;
      return Expanded(
        child: InkWell(
          onTap: () => onSelect(value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 22 / 2,
                color: active ? AppColors.primaryDark : AppColors.ink,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.primaryTintAlt,
      ),
      child: Row(
        children: [
          item('Any Time', OperatingHoursFilter.anyTime),
          item('Open Now', OperatingHoursFilter.openNow),
          item('24 Hours', OperatingHoursFilter.twentyFourHours),
        ],
      ),
    );
  }
}

class _DistanceRow extends StatelessWidget {
  const _DistanceRow({required this.selected, required this.onSelect});

  final DistanceRadiusFilter? selected;
  final ValueChanged<DistanceRadiusFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    final current = selected ?? DistanceRadiusFilter.fiveKm;
    const eta = {
      DistanceRadiusFilter.oneKm: '~3 min',
      DistanceRadiusFilter.threeKm: '~8 min',
      DistanceRadiusFilter.fiveKm: '~14 min',
      DistanceRadiusFilter.tenKm: '~25 min',
    };

    Widget tile(DistanceRadiusFilter option) {
      final selected = current == option;
      return Expanded(
        child: InkWell(
          onTap: () => onSelect(option),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryDark
                  : AppColors.primaryTintAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${option.kilometers} km',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  eta[option]!,
                  style: TextStyle(
                    fontSize: 11,
                    color: selected ? Colors.white70 : AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tile(DistanceRadiusFilter.oneKm),
        const SizedBox(width: 8),
        tile(DistanceRadiusFilter.threeKm),
        const SizedBox(width: 8),
        tile(DistanceRadiusFilter.fiveKm),
        const SizedBox(width: 8),
        tile(DistanceRadiusFilter.tenKm),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedIcon,
    this.fullWidth = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? selectedIcon;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : AppColors.primaryTintAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 24 / 2,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
            ),
            if (selected && selectedIcon != null) ...[
              const SizedBox(width: 5),
              Icon(selectedIcon, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
    if (!fullWidth) return child;
    return SizedBox(width: double.infinity, child: child);
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({
    required this.state,
    required this.onRetry,
    required this.onDirections,
  });

  final FacilitiesState state;
  final VoidCallback onRetry;
  final ValueChanged<Facility> onDirections;

  @override
  Widget build(BuildContext context) {
    if (state is FacilitiesLoading || state is FacilitiesInitial) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is FacilitiesError) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (state as FacilitiesError).message,
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 10),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    final loaded = state as FacilitiesLoaded;
    if (loaded.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No facilities match your current filters.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try widening radius, switching category, or clearing filters.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      );
    }

    return Column(
      children: loaded.facilities
          .map(
            (facility) => _SearchResultCard(
              facility: facility,
              onDirections: onDirections,
            ),
          )
          .toList(),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.facility, required this.onDirections});

  final Facility facility;
  final ValueChanged<Facility> onDirections;

  bool get _isOpenNow {
    final opening = facility.openingHours.toLowerCase();
    return opening.contains('24') || opening.contains('open');
  }

  @override
  Widget build(BuildContext context) {
    final langs = facility.languages.isEmpty
        ? null
        : facility.languages.join(' / ');
    final distance = facility.distanceKm == null
        ? null
        : '${facility.distanceKm!.toStringAsFixed(1)} km';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              facility.type == 'pharmacy'
                  ? Icons.local_pharmacy_outlined
                  : Icons.local_hospital_outlined,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        facility.name,
                        style: const TextStyle(
                          fontSize: 17 / 1.3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (_isOpenNow)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF80F2C8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Open Now',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${distance ?? 'Distance unavailable'} • ${facility.area}',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (facility.acceptedPlanIds.any((id) => id == 'rssb'))
                      _smallTag('RSSB accepted'),
                    if (langs != null) _smallTag(langs),
                  ],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => onDirections(facility),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.navigation_outlined,
                        size: 15,
                        color: AppColors.primaryDark,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Direct Directions',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.primaryTintAlt,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.resultCount,
    required this.onClear,
    required this.onShowResults,
  });

  final int resultCount;
  final VoidCallback onClear;
  final VoidCallback onShowResults;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: onShowResults,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text('Show $resultCount Results  →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsuranceOption {
  const _InsuranceOption(this.id, this.label);
  final String id;
  final String label;
}

class _NeedOption {
  const _NeedOption(this.need, this.label);
  final SpecificNeedFilter need;
  final String label;
}
