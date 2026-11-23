import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_finder/features/profile/presentation/profile_screen.dart';
import 'package:pharma_finder/services/user_profile.dart';

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

  Future<void> pumpProfile(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ProfileScreen(user: _testUser)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('profile passport lays out on a 360x800 phone', (tester) async {
    usePhoneViewport(tester);
    await pumpProfile(tester);

    expect(find.text('Profile Passport'), findsOneWidget);
    expect(find.text('Sarah Mukamana'), findsOneWidget);
    expect(find.text('sarah@example.rw'), findsOneWidget);
    expect(find.text('+250 788 123 456'), findsOneWidget);
    // No Firestore document in tests, so policy fields show the fallback.
    expect(find.text('My Insurance Policy'), findsOneWidget);
    expect(find.text('Not set'), findsNWidgets(2));
    expect(find.text('Settings & Support'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('radius slider snaps to 1/5/10/25 km and updates the pill', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await pumpProfile(tester);

    // Pill and the tick label under the track both show the current value.
    expect(find.text('5 km'), findsNWidgets(2));

    final slider = find.byType(Slider);
    await tester.ensureVisible(slider);
    await tester.pumpAndSettle();
    await tester.drag(slider, const Offset(400, 0));
    await tester.pumpAndSettle();

    expect(find.text('25 km'), findsNWidgets(2));
    expect(find.text('5 km'), findsOneWidget);

    await tester.drag(slider, const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('1 km'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('discovery toggles start on and flip when tapped', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await pumpProfile(tester);

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));
    expect(tester.widget<Switch>(switches.at(0)).value, isTrue);
    expect(tester.widget<Switch>(switches.at(1)).value, isTrue);

    await tester.ensureVisible(switches.at(0));
    await tester.pumpAndSettle();
    await tester.tap(switches.at(0));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(switches.at(0)).value, isFalse);

    await tester.tap(switches.at(1));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(switches.at(1)).value, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('log out asks for confirmation before doing anything', (
    tester,
  ) async {
    usePhoneViewport(tester);
    await pumpProfile(tester);

    final logout = find.text('Log Out of MediMatch');
    await tester.ensureVisible(logout);
    await tester.pumpAndSettle();
    await tester.tap(logout);
    await tester.pumpAndSettle();

    expect(find.text('Log out of MediMatch?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Log out of MediMatch?'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings row opens its placeholder page', (tester) async {
    usePhoneViewport(tester);
    await pumpProfile(tester);

    final row = find.text('Duty Roster Alerts');
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();

    expect(
      find.text('Duty Roster Alerts will be available soon.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
