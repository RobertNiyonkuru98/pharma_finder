import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_finder/services/auth_helpers.dart';

void main() {
  group('normalizeRwandanPhone', () {
    test('keeps national format unchanged', () {
      expect(normalizeRwandanPhone('788123456'), '+250788123456');
    });

    test('strips the local leading zero and separators', () {
      expect(normalizeRwandanPhone('0788 123 456'), '+250788123456');
      expect(normalizeRwandanPhone('073-456-7890'), '+250734567890');
    });

    test(
      'handles international prefixes without duplicating the country code',
      () {
        expect(normalizeRwandanPhone('+250 788 123 456'), '+250788123456');
        expect(normalizeRwandanPhone('250788123456'), '+250788123456');
        expect(normalizeRwandanPhone('00250788123456'), '+250788123456');
      },
    );
  });

  group('formatRwandanPhone', () {
    test('groups Rwandan numbers for display', () {
      expect(formatRwandanPhone('+250788123456'), '+250 788 123 456');
      expect(formatRwandanPhone('0788 123 456'), '+250 788 123 456');
      expect(formatRwandanPhone('788443210'), '+250 788 443 210');
    });

    test('leaves unsupported values untouched', () {
      expect(formatRwandanPhone('+254700000000'), '+254700000000');
      expect(formatRwandanPhone('n/a'), 'n/a');
    });
  });

  group('isValidRwandanPhone', () {
    test('accepts all mobile prefixes', () {
      expect(isValidRwandanPhone('0721234567'), isTrue);
      expect(isValidRwandanPhone('0731234567'), isTrue);
      expect(isValidRwandanPhone('0781234567'), isTrue);
      expect(isValidRwandanPhone('0791234567'), isTrue);
    });

    test('rejects incomplete, non-mobile and non-Rwandan numbers', () {
      expect(isValidRwandanPhone(''), isFalse);
      expect(isValidRwandanPhone('78812345'), isFalse);
      expect(isValidRwandanPhone('7881234567'), isFalse);
      expect(isValidRwandanPhone('0741234567'), isFalse);
      expect(isValidRwandanPhone('+254788123456'), isFalse);
    });
  });

  group('friendlyAuthError', () {
    FirebaseAuthException error(String code) =>
        FirebaseAuthException(code: code, message: 'raw server message');

    test('explains provider mismatch for email sign-in', () {
      final message = friendlyAuthError(
        error('invalid-credential'),
        mode: 'email',
      );
      expect(message, contains('Google'));
      expect(message, isNot(contains('raw server message')));
    });

    test('maps OTP failures to actionable messages', () {
      expect(
        friendlyAuthError(error('invalid-verification-code'), mode: 'phone'),
        contains('SMS code is incorrect'),
      );
      expect(
        friendlyAuthError(error('session-expired'), mode: 'phone'),
        contains('expired'),
      );
    });

    test('falls back to the server message for unknown codes', () {
      expect(friendlyAuthError(error('something-new')), 'raw server message');
    });
  });
}
