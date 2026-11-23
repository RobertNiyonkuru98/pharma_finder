import 'package:equatable/equatable.dart';

import '../../domain/entities/facility.dart';

enum FacilityQuickFilter { pharmacies, hospitals, openNow }

enum FacilityCategoryFilter { allCare, pharmacies, hospitals }

enum OperatingHoursFilter { anyTime, openNow, twentyFourHours }

enum DistanceRadiusFilter {
  oneKm(1),
  threeKm(3),
  fiveKm(5),
  tenKm(10);

  const DistanceRadiusFilter(this.kilometers);
  final int kilometers;
}

enum SpecificNeedFilter {
  prescriptionRefill,
  overTheCounter,
  maternalCare,
  emergencyTriage,
}

abstract class FacilitiesState extends Equatable {
  const FacilitiesState();

  @override
  List<Object?> get props => [];
}

class FacilitiesInitial extends FacilitiesState {}

class FacilitiesLoading extends FacilitiesState {}

class FacilitiesLoaded extends FacilitiesState {
  final List<Facility> facilities;
  final Set<FacilityQuickFilter> activeQuickFilters;
  final String query;
  final FacilityCategoryFilter category;
  final Set<String> selectedInsurancePlanIds;
  final OperatingHoursFilter operatingHoursFilter;
  final DistanceRadiusFilter distanceRadiusFilter;
  final Set<SpecificNeedFilter> selectedNeeds;

  const FacilitiesLoaded(
    this.facilities, {
    this.activeQuickFilters = const <FacilityQuickFilter>{},
    this.query = '',
    this.category = FacilityCategoryFilter.allCare,
    this.selectedInsurancePlanIds = const <String>{},
    this.operatingHoursFilter = OperatingHoursFilter.anyTime,
    this.distanceRadiusFilter = DistanceRadiusFilter.fiveKm,
    this.selectedNeeds = const <SpecificNeedFilter>{},
  });

  bool get isEmpty => facilities.isEmpty;

  @override
  List<Object?> get props => [
    facilities,
    activeQuickFilters,
    query,
    category,
    selectedInsurancePlanIds,
    operatingHoursFilter,
    distanceRadiusFilter,
    selectedNeeds,
  ];
}

class FacilitiesError extends FacilitiesState {
  final String message;

  const FacilitiesError(this.message);

  @override
  List<Object?> get props => [message];
}
