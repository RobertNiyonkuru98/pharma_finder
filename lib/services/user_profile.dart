import 'package:firebase_auth/firebase_auth.dart';

import 'auth_helpers.dart';

/// The account details of the person currently using the app.
///
/// Built from the Firebase Auth user so every screen shows the same identity
/// the person signed in with.
class UserProfile {
  const UserProfile({
    required this.fullName,
    this.email,
    this.phone,
    this.photoUrl,
  });

  final String fullName;
  final String? email;
  final String? phone;
  final String? photoUrl;

  /// Snapshot of the signed-in account, or a guest profile when browsing
  /// without an account (the "Continue as Guest Explorer" path).
  factory UserProfile.current() {
    final user = FirebaseAuth.instance.currentUser;
    return user == null
        ? const UserProfile(fullName: 'Guest Explorer')
        : UserProfile.fromFirebaseUser(user);
  }

  factory UserProfile.fromFirebaseUser(User user) {
    final displayName = user.displayName?.trim() ?? '';
    return UserProfile(
      fullName: displayName.isNotEmpty
          ? displayName
          : _fallbackName(user.email, user.phoneNumber),
      email: user.email,
      phone: user.phoneNumber,
      photoUrl: user.photoURL,
    );
  }

  static String _fallbackName(String? email, String? phone) {
    if (email != null && email.contains('@')) {
      final local = email
          .split('@')
          .first
          .replaceAll(RegExp(r'[._-]+'), ' ')
          .trim();
      final words = local
          .split(' ')
          .where((word) => word.isNotEmpty)
          .map(_capitalize)
          .join(' ');
      if (words.isNotEmpty) return words;
    }
    if (phone != null && phone.isNotEmpty) return formatRwandanPhone(phone);
    return 'MediMatch member';
  }

  static String _capitalize(String word) =>
      word[0].toUpperCase() + word.substring(1);

  bool get hasEmail => email != null && email!.trim().isNotEmpty;

  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;

  /// Display form of the phone number, e.g. `+250 788 123 456`.
  String get formattedPhone => hasPhone ? formatRwandanPhone(phone!) : '';

  /// Secondary account line: the verified email or a membership label.
  String get accountLine => hasEmail ? email! : 'Verified MediMatch member';

  /// Up to two letters used by the avatar placeholder.
  String get initials {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'MM';

    String letterOf(String word) {
      final letters = word.replaceAll(RegExp(r'[^A-Za-z]'), '');
      return letters.isEmpty ? '' : letters[0].toUpperCase();
    }

    final first = letterOf(words.first);
    final last = words.length > 1 ? letterOf(words.last) : '';
    final result = '$first$last';
    return result.isEmpty ? 'MM' : result;
  }
}
