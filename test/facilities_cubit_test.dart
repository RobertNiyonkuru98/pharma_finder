import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_finder/features/facilities/presentation/cubit/facilities_cubit.dart';
import 'package:pharma_finder/features/facilities/presentation/cubit/facilities_state.dart';

/// UNIT test — the Cubit in isolation, no widgets, no Firebase.
///
/// This is the template for every other feature's unit test.
void main() {
  group('FacilitiesCubit', () {
    test('starts in Initial state', () {
      expect(FacilitiesCubit().state, isA<FacilitiesInitial>());
    });

    test('load() emits Loading then Loaded with data', () async {
      final cubit = FacilitiesCubit();
      final seen = <String>[];
      final sub = cubit.stream.listen(
        (s) => seen.add(s.runtimeType.toString()),
      );

      await cubit.load();

      expect(seen, contains('FacilitiesLoading'));
      expect(cubit.state, isA<FacilitiesLoaded>());
      expect((cubit.state as FacilitiesLoaded).facilities, isNotEmpty);

      await sub.cancel();
    });

    test('search() narrows results by name', () async {
      final cubit = FacilitiesCubit();
      await cubit.load();

      cubit.search('kibagabaga');

      final state = cubit.state as FacilitiesLoaded;
      expect(state.facilities.length, 1);
      expect(state.facilities.single.name, contains('Kibagabaga'));
    });

    test(
      'search() with no match yields empty, triggering the empty state',
      () async {
        final cubit = FacilitiesCubit();
        await cubit.load();

        cubit.search('zzzz-not-a-facility');

        expect((cubit.state as FacilitiesLoaded).isEmpty, isTrue);
      },
    );

    test('filterByPlan() keeps only facilities accepting that plan', () async {
      final cubit = FacilitiesCubit();
      await cubit.load();

      cubit.filterByPlan('Mutuelle');

      final state = cubit.state as FacilitiesLoaded;
      expect(state.facilities, isNotEmpty);
      expect(
        state.facilities.every((f) => f.acceptedPlans.contains('Mutuelle')),
        isTrue,
      );
    });

    test('filterByPlan("All") restores the full list', () async {
      final cubit = FacilitiesCubit();
      await cubit.load();
      cubit.filterByPlan('Mutuelle');

      cubit.filterByPlan('All');

      expect(
        (cubit.state as FacilitiesLoaded).facilities.length,
        greaterThan(1),
      );
    });
  });
}
