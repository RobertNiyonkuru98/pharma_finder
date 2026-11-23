import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pharma_finder/core/firestore/user_repository.dart';
import 'package:pharma_finder/core/theme/app_theme.dart';
import 'package:pharma_finder/features/insurance/presentation/screens/insurance_screen.dart';

import '../../domain/entities/facility.dart';
import '../cubit/facilities_cubit.dart';
import '../cubit/facilities_state.dart';
import '../widgets/home_sections.dart';

/// Template screen — the pattern every other feature copies.
///
/// Note the three branches: loading, empty/error, and loaded. A screen that
/// only renders the happy path loses marks, and looks broken on a real device.
class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({super.key, this.onOpenSearch, this.onOpenProfile});

  final VoidCallback? onOpenSearch;
  final VoidCallback? onOpenProfile;

  @override
  State<FacilitiesScreen> createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<String> _loadPolicyName() async {
    final uid = UserRepository.currentUid;
    if (uid == null) return 'Not selected yet';

    final profile = await UserRepository.fetchProfile(uid);
    if (profile == null) return 'Not selected yet';

    final insurancePlanName = profile['insurancePlanName']?.toString().trim();
    if (insurancePlanName != null && insurancePlanName.isNotEmpty) {
      return insurancePlanName;
    }

    final coverage = profile['coverage']?.toString().trim();
    if (coverage != null && coverage.isNotEmpty) return coverage;

    return 'Not selected yet';
  }

  void _onSearchSubmitted() {
    final query = _searchController.text.trim();
    context.read<FacilitiesCubit>().search(query);
    widget.onOpenSearch?.call();
  }

  void _openInsuranceFlow() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const InsuranceScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<FacilitiesCubit, FacilitiesState>(
          builder: (context, state) {
            final selectedFilters = state is FacilitiesLoaded
                ? state.activeQuickFilters
                : <FacilityQuickFilter>{};

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                HomeHeader(onProfileTap: widget.onOpenProfile ?? () {}),
                const SizedBox(height: 16),
                FutureBuilder<String>(
                  future: _loadPolicyName(),
                  builder: (context, snapshot) {
                    final planName =
                        snapshot.data ??
                        (snapshot.connectionState == ConnectionState.waiting
                            ? 'Loading policy...'
                            : 'Not selected yet');
                    return ActivePolicyCard(
                      planName: planName,
                      onChangeTap: _openInsuranceFlow,
                    );
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onSubmitted: (_) => _onSearchSubmitted(),
                  decoration: InputDecoration(
                    hintText: 'Search pharmacies, hospitals, meds...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.muted,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _onSearchSubmitted,
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.muted,
                      ),
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
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                QuickFiltersRow(
                  selected: selectedFilters,
                  onToggle: (filter) =>
                      context.read<FacilitiesCubit>().toggleQuickFilter(filter),
                ),
                const SizedBox(height: 12),
                const CareMapCard(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nearby Providers',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onOpenSearch,
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildProvidersState(state),
                const SizedBox(height: 16),
                const EmergencyAssistanceBanner(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProvidersState(FacilitiesState state) {
    if (state is FacilitiesLoading || state is FacilitiesInitial) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state is FacilitiesError) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.message, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => context.read<FacilitiesCubit>().load(),
              style: FilledButton.styleFrom(minimumSize: const Size(110, 38)),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state is FacilitiesLoaded) {
      if (state.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Text(
            'No providers matched your current filters.',
            style: TextStyle(color: AppColors.muted),
          ),
        );
      }

      return SizedBox(
        height: 380,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: state.facilities.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            return ProviderCard(
              facility: state.facilities[i],
              onViewDetails: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Facility details coming soon.'),
                  ),
                );
              },
            );
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class FacilityTile extends StatelessWidget {
  final Facility facility;

  const FacilityTile(this.facility, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        facility.type == 'pharmacy'
            ? Icons.local_pharmacy_outlined
            : Icons.local_hospital_outlined,
      ),
      title: Text(facility.name),
      subtitle: Text('${facility.area} · ${facility.openingHours}'),
      trailing: facility.hasStock
          ? const Icon(Icons.check_circle_outline, color: Colors.green)
          : const Icon(Icons.error_outline, color: Colors.orange),
    );
  }
}
