import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/facility.dart';
import 'facilities_state.dart';

/// Template Cubit — the pattern every other feature copies.
///
/// Screen -> Cubit -> State -> widget.
///
/// Deliberately returns hardcoded data for now so the UI can be built before
/// Firebase exists. David replaces [_sample] with a Firestore repository call
/// in `features/facilities/data/`.
class FacilitiesCubit extends Cubit<FacilitiesState> {
  FacilitiesCubit() : super(FacilitiesInitial());

  Future<void> load() async {
    emit(FacilitiesLoading());
    try {
      // TODO(david): replace with FacilityRepository.watchAll()
      await Future<void>.delayed(const Duration(milliseconds: 300));
      emit(const FacilitiesLoaded(_sample));
    } catch (error) {
      emit(FacilitiesError(error.toString()));
    }
  }

  /// Filter used by the search field. Kept in the Cubit, not the widget, so it
  /// stays testable without pumping a screen.
  void search(String query) {
    final current = state;
    if (current is! FacilitiesLoaded) return;

    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      emit(const FacilitiesLoaded(_sample));
      return;
    }

    emit(
      FacilitiesLoaded(
        _sample
            .where(
              (f) =>
                  f.name.toLowerCase().contains(q) ||
                  f.area.toLowerCase().contains(q),
            )
            .toList(),
      ),
    );
  }

  void filterByPlan(String plan) {
    if (plan == 'All') {
      emit(const FacilitiesLoaded(_sample));
      return;
    }
    emit(
      FacilitiesLoaded(
        _sample.where((f) => f.acceptedPlans.contains(plan)).toList(),
      ),
    );
  }

  static const List<Facility> _sample = [
    Facility(
      id: 'f1',
      name: 'Kigali Care Pharmacy',
      type: 'pharmacy',
      area: 'Remera',
      openingHours: '08:00 - 22:00',
      acceptedPlans: ['Mutuelle', 'Britam'],
    ),
    Facility(
      id: 'f2',
      name: 'Kibagabaga Hospital',
      type: 'hospital',
      area: 'Kibagabaga',
      openingHours: '24 hours',
      acceptedPlans: ['Mutuelle', 'RSSB'],
    ),
    Facility(
      id: 'f3',
      name: 'Nyarutarama Clinic',
      type: 'clinic',
      area: 'Nyarutarama',
      openingHours: '07:30 - 20:00',
      acceptedPlans: ['Britam', 'Old Mutual'],
      hasStock: false,
    ),
  ];
}
