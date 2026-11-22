import 'package:firebase_auth/firebase_auth.dart';

/// Normalises Rwandan mobile numbers to E.164 (`+2507XXXXXXXX`).
///
/// Accepts local (`0788 123 456`), national (`788 123 456`), international
/// (`250788123456`, `+250788123456`) and `00250...` forms so that the number
/// used to register is exactly the number used to sign in.
String normalizeRwandanPhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');

  if (digits.startsWith('00250')) {
    digits = digits.substring(5);
  } else if (digits.startsWith('250') && digits.length > 9) {
    digits = digits.substring(3);
  }

  if (digits.startsWith('0') && digits.length > 9) {
    digits = digits.substring(1);
  }

  return '+250$digits';
}

/// Rwanda mobile numbers are 9 digits: 7 followed by 2, 3, 8 or 9.
bool isValidRwandanPhone(String raw) =>
    RegExp(r'^\+2507[2389]\d{7}$').hasMatch(normalizeRwandanPhone(raw));

/// Turns raw Firebase Auth failures into messages that tell the user what to
/// do next. [mode] is `'email'`, `'phone'` or `'google'`.
String friendlyAuthError(Object error, {String mode = 'email'}) {
  if (error is! FirebaseAuthException) {
    return 'Something went wrong. Please check your connection and try again.';
  }

  switch (error.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      if (mode == 'email') {
        return 'Email or password is incorrect. If you created this account with Google or your phone number, use that button instead.';
      }
      return 'The sign-in credential is invalid or has expired. Please try again.';
    case 'account-exists-with-different-credential':
      return 'This email is already registered with a different sign-in method. Use that method instead.';
    case 'invalid-verification-code':
      return 'That SMS code is incorrect. Please check it and try again.';
    case 'invalid-verification-id':
    case 'session-expired':
      return 'The SMS code has expired. Please request a new one.';
    case 'invalid-phone-number':
      return 'Enter a valid Rwandan mobile number, e.g. 788 123 456.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a few minutes and try again.';
    case 'email-already-in-use':
      return 'An account already exists for this email. Please sign in instead.';
    case 'weak-password':
      return 'Password is too weak. Use at least 6 characters.';
    case 'network-request-failed':
      return 'Network error. Check your connection and try again.';
    case 'operation-not-allowed':
      return 'This sign-in method is not enabled for the Firebase project yet.';
    default:
      return error.message ?? 'Sign-in failed. Please try again.';
  }
}
