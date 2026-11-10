// WIDGET test - the app rendered, states observed, real data displayed.
//
// Copy this pattern for every screen: pump the widget, assert the loading
// state, settle, then assert the loaded state. A screen is not "done" until
// this passes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pharma_finder/main.dart';

void main() {
  testWidgets('shows a loading spinner, then the facility list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PharmaFinderApp());

    // First frame: the Cubit emitted Loading, nothing fetched yet.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the faked fetch complete.
    await tester.pumpAndSettle();

    expect(find.text('Find care'), findsOneWidget);
    expect(find.text('Kigali Care Pharmacy'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('renders the out-of-stock marker for a facility without stock', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PharmaFinderApp());
    await tester.pumpAndSettle();

    expect(find.text('Nyarutarama Clinic'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });
}
