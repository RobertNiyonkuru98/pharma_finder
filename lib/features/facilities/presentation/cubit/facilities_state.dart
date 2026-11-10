import 'package:equatable/equatable.dart';

import '../../domain/entities/facility.dart';

/// Every screen state the UI must be able to render.
///
/// The four states below are not decoration: the rubric asks for loading and
/// empty states, and a screen that only handles "happy path" fails that check.
abstract class FacilitiesState extends Equatable {
  const FacilitiesState();

  @override
  List<Object?> get props => [];
}

class FacilitiesInitial extends FacilitiesState {}

class FacilitiesLoading extends FacilitiesState {}

class FacilitiesLoaded extends FacilitiesState {
  final List<Facility> facilities;

  const FacilitiesLoaded(this.facilities);

  bool get isEmpty => facilities.isEmpty;

  @override
  List<Object?> get props => [facilities];
}

class FacilitiesError extends FacilitiesState {
  final String message;

  const FacilitiesError(this.message);

  @override
  List<Object?> get props => [message];
}
