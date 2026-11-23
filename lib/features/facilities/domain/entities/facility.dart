import 'package:equatable/equatable.dart';
class Facility extends Equatable {
  final String id;
  final String name;
  final String type; 
  final String area;
  final String openingHours;
  final List<String> acceptedPlans; 
  final List<String> acceptedPlanIds; 
  final bool hasStock;
  final double? rating;
  final double? distanceKm;
  final String? imageUrl;
  final String? phone;
  final List<String> languages;
  final List<String>
  serviceTags;

  const Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.area,
    required this.openingHours,
    this.acceptedPlans = const [],
    this.acceptedPlanIds = const [],
    this.hasStock = true,
    this.rating,
    this.distanceKm,
    this.imageUrl,
    this.phone,
    this.languages = const [],
    this.serviceTags = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    area,
    openingHours,
    acceptedPlans,
    acceptedPlanIds,
    hasStock,
    rating,
    distanceKm,
    imageUrl,
    phone,
    languages,
    serviceTags,
  ];
}
