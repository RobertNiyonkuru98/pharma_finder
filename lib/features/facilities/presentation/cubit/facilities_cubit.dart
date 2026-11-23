import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/facility.dart';
import 'facilities_state.dart';

class FacilitiesCubit extends Cubit<FacilitiesState> {
  FacilitiesCubit() : super(FacilitiesInitial());

  String _query = '';
  FacilityCategoryFilter _categoryFilter = FacilityCategoryFilter.allCare;
  OperatingHoursFilter _operatingHoursFilter = OperatingHoursFilter.anyTime;
  DistanceRadiusFilter _distanceRadiusFilter = DistanceRadiusFilter.fiveKm;
  final Set<String> _selectedInsurancePlanIds = <String>{};
  final Set<SpecificNeedFilter> _selectedNeeds = <SpecificNeedFilter>{};
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

  void clearSearch() {
    _query = '';
    _emitFiltered();
  }

  String get query => _query;

  void setCategory(FacilityCategoryFilter category) {
    _categoryFilter = category;
    _emitFiltered();
  }

  void toggleInsurancePlan(String planId) {
    if (_selectedInsurancePlanIds.contains(planId)) {
      _selectedInsurancePlanIds.remove(planId);
    } else {
      _selectedInsurancePlanIds.add(planId);
    }
    _emitFiltered();
  }

  bool isInsuranceSelected(String planId) =>
      _selectedInsurancePlanIds.contains(planId);

  void setOperatingHoursFilter(OperatingHoursFilter filter) {
    _operatingHoursFilter = filter;
    _emitFiltered();
  }

  void setDistanceRadiusFilter(DistanceRadiusFilter filter) {
    _distanceRadiusFilter = filter;
    _emitFiltered();
  }

  void toggleSpecificNeed(SpecificNeedFilter need) {
    if (_selectedNeeds.contains(need)) {
      _selectedNeeds.remove(need);
    } else {
      _selectedNeeds.add(need);
    }
    _emitFiltered();
  }

  bool isSpecificNeedSelected(SpecificNeedFilter need) =>
      _selectedNeeds.contains(need);

  void clearFilters() {
    _query = '';
    _categoryFilter = FacilityCategoryFilter.allCare;
    _operatingHoursFilter = OperatingHoursFilter.anyTime;
    _distanceRadiusFilter = DistanceRadiusFilter.fiveKm;
    _selectedInsurancePlanIds.clear();
    _selectedNeeds.clear();
    _activeQuickFilters.clear();
    _emitFiltered();
  }

  void filterByPlan(String plan) {
    if (plan == 'All') {
      _selectedInsurancePlanIds.clear();
      _emitFiltered();
      return;
    }

    final mapped = _normalizePlanId(plan);
    _selectedInsurancePlanIds
      ..clear()
      ..add(mapped);
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

      if (_categoryFilter == FacilityCategoryFilter.pharmacies &&
          facility.type != 'pharmacy') {
        return false;
      }

      if (_categoryFilter == FacilityCategoryFilter.hospitals &&
          facility.type != 'hospital') {
        return false;
      }

      if (_selectedInsurancePlanIds.isNotEmpty &&
          !_matchesAnyInsurance(facility, _selectedInsurancePlanIds)) {
        return false;
      }

      if (_operatingHoursFilter == OperatingHoursFilter.openNow &&
          !_isOpenNow(facility)) {
        return false;
      }

      if (_operatingHoursFilter == OperatingHoursFilter.twentyFourHours &&
          !_is24Hours(facility)) {
        return false;
      }

      final distance = facility.distanceKm;
      if (distance == null || distance > _distanceRadiusFilter.kilometers) {
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

      if (_selectedNeeds.isNotEmpty &&
          !_selectedNeeds.any(
            (need) => facility.serviceTags.contains(_serviceTagFor(need)),
          )) {
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
        query: _query,
        category: _categoryFilter,
        selectedInsurancePlanIds: Set<String>.unmodifiable(
          _selectedInsurancePlanIds,
        ),
        operatingHoursFilter: _operatingHoursFilter,
        distanceRadiusFilter: _distanceRadiusFilter,
        selectedNeeds: Set<SpecificNeedFilter>.unmodifiable(_selectedNeeds),
      ),
    );
  }

  bool _matchesAnyInsurance(Facility facility, Set<String> selectedIds) {
    final facilityIds = {
      ...facility.acceptedPlanIds.map(_normalizePlanId),
      ...facility.acceptedPlans.map(_normalizePlanId),
    };
    return facilityIds.any(selectedIds.contains);
  }

  String _normalizePlanId(String value) {
    final v = value.toLowerCase();
    if (v.contains('rssb') || v.contains('rama')) return 'rssb';
    if (v.contains('mmi') || v.contains('military')) return 'mmi';
    if (v.contains('britam')) return 'britam';
    if (v.contains('sanlam')) return 'sanlam';
    if (v.contains('cash') || v.contains('momo')) return 'cash';
    if (v.contains('mutuelle')) return 'mutuelle';
    return v.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  String _serviceTagFor(SpecificNeedFilter need) {
    switch (need) {
      case SpecificNeedFilter.prescriptionRefill:
        return 'prescription_refill';
      case SpecificNeedFilter.overTheCounter:
        return 'over_the_counter';
      case SpecificNeedFilter.maternalCare:
        return 'maternal_care';
      case SpecificNeedFilter.emergencyTriage:
        return 'emergency_triage';
    }
  }

  bool _isOpenNow(Facility facility) {
    final openingHours = facility.openingHours.toLowerCase();
    if (_is24Hours(facility)) return true;

    final match = RegExp(
      r'(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})',
    ).firstMatch(openingHours);
    if (match == null) return false;

    final startHour = int.tryParse(match.group(1) ?? '');
    final startMinute = int.tryParse(match.group(2) ?? '');
    final endHour = int.tryParse(match.group(3) ?? '');
    final endMinute = int.tryParse(match.group(4) ?? '');
    if (startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null) {
      return false;
    }

    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
      startHour,
      startMinute,
    );
    var end = DateTime(now.year, now.month, now.day, endHour, endMinute);
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }
    final current = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );
    final adjustedCurrent = end.day != start.day && current.isBefore(start)
        ? current.add(const Duration(days: 1))
        : current;

    return !adjustedCurrent.isBefore(start) && !adjustedCurrent.isAfter(end);
  }

  bool _is24Hours(Facility facility) {
    final openingHours = facility.openingHours.toLowerCase();
    return openingHours.contains('24') || openingHours.contains('always open');
  }

  static const List<Facility> _sample = [
    Facility(
      id: 'f1',
      name: 'Kigali Care Pharmacy',
      type: 'pharmacy',
      area: 'Remera',
      openingHours: '08:00 - 22:00',
      acceptedPlans: ['Mutuelle', 'Britam'],
      acceptedPlanIds: ['mutuelle', 'britam'],
      rating: 4.6,
      distanceKm: 1.2,
      languages: ['EN', 'FR', 'RW'],
      phone: '+250788555201',
      serviceTags: ['prescription_refill', 'over_the_counter'],
      imageUrl: 'assets/images/facilities/kigali_care_pharmacy.png',
    ),
    Facility(
      id: 'f2',
      name: 'Kibagabaga Hospital',
      type: 'hospital',
      area: 'Kibagabaga',
      openingHours: '24 hours',
      acceptedPlans: ['Mutuelle', 'RSSB'],
      acceptedPlanIds: ['mutuelle', 'rssb'],
      rating: 4.4,
      distanceKm: 2.7,
      languages: ['EN', 'RW'],
      phone: '+250788303030',
      serviceTags: ['maternal_care', 'emergency_triage'],
      imageUrl: 'assets/images/facilities/kibagabaga_hospital.png',
    ),
    Facility(
      id: 'f3',
      name: 'Nyarutarama Clinic',
      type: 'clinic',
      area: 'Nyarutarama',
      openingHours: '07:30 - 20:00',
      acceptedPlans: ['Britam', 'Old Mutual'],
      acceptedPlanIds: ['britam'],
      hasStock: false,
      rating: 4.1,
      distanceKm: 3.6,
      serviceTags: ['prescription_refill', 'maternal_care'],
      imageUrl: 'assets/images/facilities/nyarutarama_clinic.png',
    ),
    Facility(
      id: 'f4',
      name: 'Pharmacie Conseil Nyarugenge',
      type: 'pharmacy',
      area: 'KN 4 Ave, Kigali',
      openingHours: '06:00 - 23:00',
      acceptedPlans: ['RSSB (RAMA)', 'MMI'],
      acceptedPlanIds: ['rssb', 'mmi'],
      rating: 4.8,
      distanceKm: 1.2,
      languages: ['EN', 'FR'],
      phone: '+250788123456',
      serviceTags: ['prescription_refill', 'over_the_counter'],
      imageUrl: 'assets/images/facilities/pharmacie_conseil.png',
    ),
  ];
}
