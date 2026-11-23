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

  String _query = '';
  String _selectedPlan = 'All';
  final Set<FacilityQuickFilter> _activeQuickFilters = <FacilityQuickFilter>{};

  Future<void> load() async {
    emit(FacilitiesLoading());
    try {
      // TODO(david): replace with FacilityRepository.watchAll()
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _emitFiltered();
    } catch (error) {
      emit(FacilitiesError(error.toString()));
    }
  }

  /// Filter used by the search field. Kept in the Cubit, not the widget, so it
  /// stays testable without pumping a screen.
  void search(String query) {
    _query = query.trim().toLowerCase();
    _emitFiltered();
  }

  void filterByPlan(String plan) {
    _selectedPlan = plan;
    _emitFiltered();
  }

  void toggleQuickFilter(FacilityQuickFilter filter) {
    if (_activeQuickFilters.contains(filter)) {
      _activeQuickFilters.remove(filter);
    } else {
      _activeQuickFilters.add(filter);
    }
    _emitFiltered();
  }

  bool isQuickFilterSelected(FacilityQuickFilter filter) =>
      _activeQuickFilters.contains(filter);

  void _emitFiltered() {
    final filtered = _sample.where((facility) {
      if (_query.isNotEmpty &&
          !facility.name.toLowerCase().contains(_query) &&
          !facility.area.toLowerCase().contains(_query)) {
        return false;
      }

      if (_selectedPlan != 'All' &&
          !facility.acceptedPlans.contains(_selectedPlan)) {
        return false;
      }

      if (_activeQuickFilters.contains(FacilityQuickFilter.pharmacies) &&
          facility.type != 'pharmacy') {
        return false;
      }

      if (_activeQuickFilters.contains(FacilityQuickFilter.hospitals) &&
          facility.type != 'hospital') {
        return false;
      }

      if (_activeQuickFilters.contains(FacilityQuickFilter.openNow) &&
          !_isOpenNow(facility)) {
        return false;
      }

      return true;
    }).toList();

    emit(
      FacilitiesLoaded(
        filtered,
        activeQuickFilters: Set<FacilityQuickFilter>.unmodifiable(
          _activeQuickFilters,
        ),
      ),
    );
  }

  bool _isOpenNow(Facility facility) {
    final openingHours = facility.openingHours.toLowerCase();
    return openingHours.contains('24');
  }

  static const List<Facility> _sample = [
    Facility(
      id: 'f1',
      name: 'Kigali Care Pharmacy',
      type: 'pharmacy',
      area: 'Remera',
      openingHours: '08:00 - 22:00',
      acceptedPlans: ['Mutuelle', 'Britam'],
      rating: 4.6,
      distanceKm: 1.2,
      languages: ['EN', 'FR', 'RW'],
      phone: '+250788555201',
    ),
    Facility(
      id: 'f2',
      name: 'Kibagabaga Hospital',
      type: 'hospital',
      area: 'Kibagabaga',
      openingHours: '24 hours',
      acceptedPlans: ['Mutuelle', 'RSSB'],
      rating: 4.4,
      distanceKm: 2.7,
      languages: ['EN', 'RW'],
      phone: '+250788303030',
    ),
    Facility(
      id: 'f3',
      name: 'Nyarutarama Clinic',
      type: 'clinic',
      area: 'Nyarutarama',
      openingHours: '07:30 - 20:00',
      acceptedPlans: ['Britam', 'Old Mutual'],
      hasStock: false,
      rating: 4.1,
      distanceKm: 3.6,
    ),
  ];
}
