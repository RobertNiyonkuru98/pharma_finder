import 'package:equatable/equatable.dart';

import '../../domain/entities/insurance_plan.dart';

/// State for the insurance selection screen.
///
/// One immutable state with copyWith rather than four state classes: this
/// screen has no error/empty branch worth a separate type, and the list is
/// static so it can never be empty.
class InsuranceState extends Equatable {
  final List<InsurancePlan> plans;
  final String? selectedId;
  final String query;
  final bool submitting;
  final String? error;

  const InsuranceState({
    this.plans = InsurancePlan.defaults,
    this.selectedId,
    this.query = '',
    this.submitting = false,
    this.error,
  });

  InsurancePlan? get selected {
    if (selectedId == null) return null;
    for (final plan in plans) {
      if (plan.id == selectedId) return plan;
    }
    return null;
  }

  /// Plans matching the search field.
  List<InsurancePlan> get visible {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return plans;
    return plans
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q),
        )
        .toList();
  }

  bool get canContinue => selectedId != null && !submitting;

  InsuranceState copyWith({
    List<InsurancePlan>? plans,
    String? selectedId,
    String? query,
    bool? submitting,
    String? error,
    bool clearError = false,
  }) {
    return InsuranceState(
      plans: plans ?? this.plans,
      selectedId: selectedId ?? this.selectedId,
      query: query ?? this.query,
      submitting: submitting ?? this.submitting,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [plans, selectedId, query, submitting, error];
}
