import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pharma_finder/core/router/app_shell.dart';
import 'package:pharma_finder/core/theme/app_theme.dart';
import 'package:pharma_finder/features/insurance/domain/entities/insurance_plan.dart';
import 'package:pharma_finder/features/insurance/presentation/cubit/insurance_cubit.dart';
import 'package:pharma_finder/features/insurance/presentation/cubit/insurance_state.dart';
import 'package:pharma_finder/features/location/presentation/live_location_screen.dart';

/// "Choose your insurance" — matches the Figma screen of the same name.
///
/// This is the post-auth landing point: both login and signup replace
/// themselves with this screen, so it also owns the hand-off into [AppShell].
class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  Future<void> _continue(BuildContext context) async {
    final cubit = context.read<InsuranceCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    void goNext() => navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const LiveLocationScreen()),
    );

    final outcome = await cubit.saveSelection();
    if (!context.mounted) return;

    final message = cubit.state.error ?? 'Could not save your selection.';
    messenger.hideCurrentSnackBar();

    switch (outcome) {
      case SaveOutcome.saved:
        goNext();
      case SaveOutcome.guest:
        // The messenger belongs to MaterialApp, so this survives the route swap.
        messenger.showSnackBar(SnackBar(content: Text(message)));
        goNext();
      case SaveOutcome.failed:
        // Stay here so the user can retry, but don't trap them offline.
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(label: 'Continue anyway', onPressed: goNext),
          ),
        );
      case SaveOutcome.noChoice:
        messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InsuranceCubit(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: SafeArea(
              child: BlocBuilder<InsuranceCubit, InsuranceState>(
                builder: (context, state) {
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
                              'Choose your insurance',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const Text(
                              "We'll use this to pinpoint clinics, hospitals, and "
                              'pharmacies that accept your coverage across Kigali '
                              'and beyond.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _SearchField(state: state),
                            const SizedBox(height: AppSpacing.md),
                            if (state.visible.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Center(
                                  child: Text(
                                    'No scheme matches that search.',
                                    style: TextStyle(color: AppColors.muted),
                                  ),
                                ),
                              )
                            else
                              for (final plan in state.visible)
                                _PlanCard(
                                  plan: plan,
                                  selected: plan.id == state.selectedId,
                                  onTap: () => context
                                      .read<InsuranceCubit>()
                                      .select(plan.id),
                                ),
                            const SizedBox(height: AppSpacing.md),
                            const _InfoNote(),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: FilledButton(
                          onPressed: state.canContinue
                              ? () => _continue(context)
                              : null,
                          child: state.submitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Continue'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    // Login/signup *replace* themselves with this screen, so there is usually
    // nothing behind it. Only offer Back when it actually goes somewhere.
    final canGoBack = ModalRoute.of(context)?.canPop ?? false;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        canGoBack ? AppSpacing.sm : AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          if (canGoBack) ...[
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back, size: 20),
              color: AppColors.ink,
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.4,
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

class _SearchField extends StatefulWidget {
  final InsuranceState state;

  const _SearchField({required this.state});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    context.read<InsuranceCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: (v) => context.read<InsuranceCubit>().search(v),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search provider (e.g. RSSB, MMI, Britam)',
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.muted),
        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.muted),
        suffixIcon: widget.state.query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: _clear,
                icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
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
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final InsurancePlan plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? AppColors.primaryTintAlt : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  // Recommended schemes get a mint tile and a verified shield
                  // so they stand out even when they carry no badge text.
                  decoration: BoxDecoration(
                    color: plan.isRecommended
                        ? AppColors.primaryTint
                        : AppColors.lavender,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    plan.isRecommended
                        ? Icons.verified_user
                        : Icons.shield_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
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
                              plan.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (plan.badge != null) ...[
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
                                plan.badge!,
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
                        '${plan.category} • ${plan.description}',
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote();

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
          Icon(Icons.info_outline, size: 18, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Rwanda provides emergency care irrespective of provider. '
              'You can change your scheme at any time in Profile.',
              style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
