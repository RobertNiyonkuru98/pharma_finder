import 'package:equatable/equatable.dart';

/// A healthcare facility the user can search for.
///
/// Domain layer: no Firebase, no Flutter imports. This is the shape the whole
/// app agrees on. David wires the Firestore repository to produce these.
class Facility extends Equatable {
  final String id;
  final String name;
  final String type; // pharmacy | clinic | hospital
  final String area;
  final String openingHours;
  final List<String> acceptedPlans; // e.g. ['Mutuelle', 'Britam']
  final bool hasStock;

  const Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.area,
    required this.openingHours,
    this.acceptedPlans = const [],
    this.hasStock = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    area,
    openingHours,
    acceptedPlans,
    hasStock,
  ];
}
