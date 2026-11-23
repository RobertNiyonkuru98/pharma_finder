import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pharma_finder/features/insurance/presentation/screens/insurance_screen.dart';

/// WIDGET test for the insurance screen.
///
/// This runs the real screen, so a RenderFlex overflow, a bad constraint or a
/// missing widget throws here instead of on the phone during the demo. It is
/// the closest thing to "did the UI actually lay out" that runs without Firebase.
void main() {
  testWidgets('renders the schemes and a disabled Continue', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InsuranceScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Choose your insurance'), findsOneWidget);
    expect(find.text('RSSB (RAMA)'), findsOneWidget);
    expect(find.text('Britam Insurance'), findsOneWidget);
    expect(find.text('Widely Accepted'), findsOneWidget);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull, reason: 'Continue must start disabled');
  });

  testWidgets('selecting a scheme enables Continue', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InsuranceScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Britam Insurance'));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(
      button.onPressed,
      isNotNull,
      reason: 'Continue must enable on select',
    );
  });

  testWidgets('search filters the scheme list', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InsuranceScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'military');
    await tester.pumpAndSettle();

    expect(find.text('MMI'), findsOneWidget);
    expect(find.text('RSSB (RAMA)'), findsNothing);
  });

  testWidgets('a search with no match shows the empty message', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: InsuranceScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();

    expect(find.text('No scheme matches that search.'), findsOneWidget);
  });

  testWidgets('the clear button empties the search and restores the list', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: InsuranceScreen()));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Clear search'), findsNothing);

    await tester.enterText(find.byType(TextField), 'military');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    expect(find.text('RSSB (RAMA)'), findsOneWidget);
    expect(find.byTooltip('Clear search'), findsNothing);
  });

  testWidgets('no back arrow when there is nothing to go back to', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: InsuranceScreen()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });
}
