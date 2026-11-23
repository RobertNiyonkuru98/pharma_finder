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
  testWidgets('shows home sections and nearby providers after load', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('MediMatch'), findsOneWidget);
    expect(find.text('Nearby Providers'), findsOneWidget);
    expect(find.text('Kigali Care Pharmacy'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('renders quick filters and emergency CTA', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Pharmacies'), findsOneWidget);
    expect(find.text('Hospitals'), findsOneWidget);
    expect(find.text('Open Now'), findsOneWidget);
  });
}
