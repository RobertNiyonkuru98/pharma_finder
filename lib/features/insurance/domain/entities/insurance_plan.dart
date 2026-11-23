import 'package:equatable/equatable.dart';

/// A Rwandan health insurance scheme a user can select.
///
/// Domain layer: no Flutter, no Firebase. The entries mirror the
/// "Choose your insurance" screen in the Figma design, plus Mutuelle de Santé
/// (CBHI), the community scheme most Rwandans are enrolled in.
class InsurancePlan extends Equatable {
  final String id;
  final String name;
  final String category;
  final String description;
  final String? badge;
  final bool isRecommended;

  const InsurancePlan({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.badge,
    this.isRecommended = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    description,
    badge,
    isRecommended,
  ];

  static const List<InsurancePlan> defaults = [
    InsurancePlan(
      id: 'rssb',
      name: 'RSSB (RAMA)',
      category: 'Public / National Scheme',
      description: 'Comprehensive in Rwanda',
      badge: 'Widely Accepted',
      isRecommended: true,
    ),
    InsurancePlan(
      id: 'cbhi',
      name: 'Mutuelle de Santé (CBHI)',
      category: 'Community-Based Health Insurance',
      description: 'Health centres & district hospitals',
    ),
    InsurancePlan(
      id: 'mmi',
      name: 'MMI',
      category: 'Military Medical Insurance',
      description: 'Armed Forces & Public',
    ),
    InsurancePlan(
      id: 'britam',
      name: 'Britam Insurance',
      category: 'Britam Rwanda',
      description: 'Private & Expat Triage',
    ),
    InsurancePlan(
      id: 'sanlam',
      name: 'Sanlam',
      category: 'Sanlam Vie & Non-Vie',
      description: 'Private Corporate',
    ),
    InsurancePlan(
      id: 'radiant',
      name: 'Radiant',
      category: 'Radiant Insurance Company',
      description: 'Regional Partner',
    ),
    InsurancePlan(
      id: 'international',
      name: 'Other / International',
      category: 'UAP, Prime, Old Mutual, Cigna, Allianz',
      description: 'Travel & international policies',
    ),
    InsurancePlan(
      id: 'cash',
      name: 'Pay Out of Pocket / Cash',
      category: 'Accepted at all facilities',
      description: 'MoMo, Cards & Cash',
    ),
  ];
}
