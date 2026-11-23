// WIDGET test for the facilities screen.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pharma_finder/features/facilities/presentation/cubit/facilities_cubit.dart';
import 'package:pharma_finder/features/facilities/presentation/screens/facilities_screen.dart';

Widget _harness() => BlocProvider(
  create: (_) => FacilitiesCubit()..load(),
  child: const MaterialApp(home: FacilitiesScreen()),
);

void main() {
  testWidgets('shows a spinner first, then the facility list', (tester) async {
    await tester.pumpWidget(_harness());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Find care'), findsOneWidget);
    expect(find.text('Kigali Care Pharmacy'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('renders the out-of-stock marker', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Nyarutarama Clinic'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}
