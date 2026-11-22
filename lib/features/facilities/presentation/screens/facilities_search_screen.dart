import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pharma_finder/core/theme/app_theme.dart';
import 'package:pharma_finder/features/facilities/presentation/cubit/facilities_cubit.dart';
import 'package:pharma_finder/features/facilities/presentation/cubit/facilities_state.dart';
import 'package:pharma_finder/features/facilities/presentation/screens/facilities_screen.dart';

/// The Search tab. Shares [FacilitiesCubit] with Home via [AppShell], so the
/// filter chosen here persists when the user switches tabs.
class FacilitiesSearchScreen extends StatelessWidget {
  const FacilitiesSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FacilitiesCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Directory'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              onChanged: cubit.search,
              decoration: InputDecoration(
                hintText: 'Search pharmacies, hospitals, meds...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.muted,
                ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
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
          ),
          const _PlanFilterRow(),
          Expanded(
            child: BlocBuilder<FacilitiesCubit, FacilitiesState>(
              builder: (context, state) {
                if (state is FacilitiesLoading || state is FacilitiesInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is FacilitiesError) {
                  return Center(child: Text(state.message));
                }
                if (state is FacilitiesLoaded) {
                  if (state.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nothing matches that search.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    itemCount: state.facilities.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) =>
                        FacilityTile(state.facilities[i]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanFilterRow extends StatelessWidget {
  const _PlanFilterRow();

  static const _plans = ['All', 'RSSB', 'Britam', 'Mutuelle'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 8,
        ),
        itemCount: _plans.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final plan = _plans[i];
          return ActionChip(
            label: Text(plan),
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
            labelStyle: const TextStyle(fontSize: 12, color: AppColors.ink),
            onPressed: () => context.read<FacilitiesCubit>().filterByPlan(plan),
          );
        },
      ),
    );
  }
}
