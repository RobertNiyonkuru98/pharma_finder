import 'package:flutter_test/flutter_test.dart';

import 'package:pharma_finder/features/insurance/domain/entities/insurance_plan.dart';
import 'package:pharma_finder/features/insurance/presentation/cubit/insurance_cubit.dart';

/// UNIT test for the insurance selection logic.
///
/// Nothing here touches Firebase: the Cubit only reaches the network inside
/// saveSelection(), so selection and filtering are testable in isolation. That
/// is the point of keeping the logic in the Cubit rather than the widget.
void main() {
  group('InsuranceCubit', () {
    test('starts with all eight schemes and nothing selected', () {
      final cubit = InsuranceCubit();

      expect(cubit.state.plans.length, 8);
      expect(cubit.state.selectedId, isNull);
      expect(cubit.state.selected, isNull);
      expect(cubit.state.canContinue, isFalse);
    });

    test('selecting a scheme enables Continue and exposes the entity', () {
      final cubit = InsuranceCubit();

      cubit.select('britam');

      expect(cubit.state.canContinue, isTrue);
      expect(cubit.state.selected?.name, 'Britam Insurance');
    });

    test('RSSB is marked as the recommended scheme', () {
      final cubit = InsuranceCubit();
      final rssb = cubit.state.plans.firstWhere((p) => p.id == 'rssb');

      expect(rssb.isRecommended, isTrue);
      expect(rssb.badge, 'Widely Accepted');
    });

    test('Mutuelle de Santé (CBHI) is offered and searchable', () {
      final cubit = InsuranceCubit();

      cubit.search('mutuelle');

      expect(cubit.state.visible.single.id, 'cbhi');
    });

    test('search narrows by name', () {
      final cubit = InsuranceCubit();

      cubit.search('britam');

      expect(cubit.state.visible.length, 1);
      expect(cubit.state.visible.single.name, 'Britam Insurance');
    });

    test('search matches the category line too', () {
      final cubit = InsuranceCubit();

      cubit.search('military');

      expect(cubit.state.visible.single.id, 'mmi');
    });

    test('a search with no match yields an empty list', () {
      final cubit = InsuranceCubit();

      cubit.search('zzz-not-a-scheme');

      expect(cubit.state.visible, isEmpty);
    });

    test('clearing the search restores every scheme', () {
      final cubit = InsuranceCubit();
      cubit.search('britam');

      cubit.clearSearch();

      expect(cubit.state.visible.length, InsurancePlan.defaults.length);
    });

    test(
      'saveSelection without a choice reports an error and blocks',
      () async {
        final cubit = InsuranceCubit();

        final outcome = await cubit.saveSelection();

        expect(outcome, SaveOutcome.noChoice);
        expect(cubit.state.error, isNotNull);
      },
    );
  });
}
