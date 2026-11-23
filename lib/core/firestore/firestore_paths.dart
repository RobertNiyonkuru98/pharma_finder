/// Canonical Firestore document paths used by the app.
///
/// Keeping them in one place stops screens and repositories from drifting
/// apart on collection or document names.
abstract final class FirestorePaths {
  static String userDoc(String uid) => 'users/$uid';

  static const String usersCollection = 'users';
  static const String appConfigCollection = 'app_config';
  static const String aboutDoc = 'app_config/about';
}
