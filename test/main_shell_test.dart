import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_finder/core/theme/app_colors.dart';
import 'package:pharma_finder/services/user_profile.dart';
import 'package:pharma_finder/shell/main_shell.dart';

const UserProfile _testUser = UserProfile(
  fullName: 'Sarah Mukamana',
  email: 'sarah@example.rw',
  phone: '+250788123456',
);

void main() {
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpShell(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainShell(user: _testUser)),
    );
    await tester.pumpAndSettle();
  }

  int? shellIndex(WidgetTester tester) =>
      tester.widget<IndexedStack>(find.byType(IndexedStack)).index;

  testWidgets('home tab shows the pharmacy placeholder on a 360x800 phone', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await pumpShell(tester);

    expect(shellIndex(tester), MainShell.homeTab);
    expect(find.text('Pharmacies near you'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the SOS tab holds the emergency screen for the signed-in user', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await pumpShell(tester);

    await tester.tap(find.text('SOS'));
    await tester.pumpAndSettle();

    expect(shellIndex(tester), MainShell.sosTab);
    expect(find.text('Kigali, Nyarugenge District'), findsOneWidget);
    expect(find.text('CALL 112 (AMBULANCE)'), findsOneWidget);
    // The first responder record carries the signed-in account's name.
    expect(find.text('Sarah Mukamana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom bar switches between all four tabs', (tester) async {
    usePhoneViewport(tester);
    await pumpShell(tester);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(shellIndex(tester), MainShell.searchTab);
    expect(find.text('Search pharmacies and hospitals'), findsOneWidget);

    await tester.tap(find.text('SOS'));
    await tester.pumpAndSettle();
    expect(shellIndex(tester), MainShell.sosTab);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(shellIndex(tester), MainShell.profileTab);
    expect(find.text('Profile Passport'), findsOneWidget);

    // The Profile nav item is highlighted in green; Home falls back to muted.
    TextStyle? labelColor(String label) =>
        tester.widget<Text>(find.text(label)).style;
    expect(labelColor('Profile')?.color, AppColors.primaryGreen);
    expect(labelColor('Home')?.color, AppColors.textMuted);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(shellIndex(tester), MainShell.homeTab);
    expect(tester.takeException(), isNull);
  });

  testWidgets('children can switch tabs through MainShellScope', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await pumpShell(tester);

    MainShellScope.of(tester.element(find.byType(IndexedStack))).value =
        MainShell.sosTab;
    await tester.pumpAndSettle();

    expect(shellIndex(tester), MainShell.sosTab);
  });

  testWidgets('tapping a first-aid guide opens its placeholder page', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await pumpShell(tester);

    await tester.tap(find.text('SOS'));
    await tester.pumpAndSettle();

    final guide = find.text('Severe Bleeding');
    await tester.ensureVisible(guide);
    await tester.pumpAndSettle();
    await tester.tap(guide);
    await tester.pumpAndSettle();

    expect(find.textContaining('steps are being finalised'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
