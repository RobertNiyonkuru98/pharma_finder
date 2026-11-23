import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firestore_paths.dart';

/// Typed read/write access to everything stored under `users/{uid}` and to the
/// read-only `app_config` documents.
///
/// Every write is a merge write so a screen can persist only the fields the
/// user actually edited without clobbering the rest of the document.
class UserRepository {
  UserRepository._();

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static User? get _currentUser {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (error) {
      debugPrint('FirebaseAuth unavailable: $error');
      return null;
    }
  }

  /// UID of the signed-in account, or `null` when signed out / Firebase is not
  /// available (widget tests, for example).
  static String? get currentUid => _currentUser?.uid;

  static String get currentDisplayName =>
      _currentUser?.displayName?.trim() ?? '';

  static String get currentEmail => _currentUser?.email?.trim() ?? '';

  static String get currentPhone => _currentUser?.phoneNumber?.trim() ?? '';

  /// Keeps the Firebase Auth display name aligned with the profile document.
  static Future<void> updateDisplayName(String name) async {
    final user = _currentUser;
    final trimmed = name.trim();
    if (user == null || trimmed.isEmpty) return;

    try {
      await user.updateDisplayName(trimmed);
    } catch (error) {
      debugPrint('Could not update display name: $error');
    }
  }

  /// Stamps `lastLogin` and back-fills identity fields Firestore may be
  /// missing (phone sign-ins never populate `email`, for example).
  static Future<void> recordLogin() async {
    final user = _currentUser;
    if (user == null) return;

    final displayName = user.displayName?.trim() ?? '';
    final email = user.email?.trim() ?? '';
    final phone = user.phoneNumber?.trim() ?? '';

    try {
      await _db.doc(FirestorePaths.userDoc(user.uid)).set(<String, dynamic>{
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (displayName.isNotEmpty) 'fullName': displayName,
        if (email.isNotEmpty) 'email': email,
        if (phone.isNotEmpty) 'phone': phone,
      }, SetOptions(merge: true));
    } catch (error) {
      debugPrint('Could not record sign-in: $error');
    }
  }

  // -------------------------------------------------------------------------
  // Location
  // -------------------------------------------------------------------------

  static Future<void> saveLocation({
    required String placeName,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    final uid = currentUid;
    if (uid == null) return;

    await _db.doc(FirestorePaths.userDoc(uid)).set(<String, dynamic>{
      'location': <String, dynamic>{
        'placeName': placeName,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'savedAt': FieldValue.serverTimestamp(),
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> fetchLocation(String uid) async {
    try {
      final snapshot = await _db.doc(FirestorePaths.userDoc(uid)).get();
      final data = snapshot.data();
      final location = data?['location'];
      return location is Map<String, dynamic> ? location : null;
    } catch (error) {
      debugPrint('Could not load saved location: $error');
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // Profile
  // -------------------------------------------------------------------------

  /// Merges [data] into `users/{uid}`.
  ///
  /// Empty values are dropped so a blank form field never erases a stored
  /// name, email or phone number.
  static Future<void> saveProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    final sanitized = <String, dynamic>{
      for (final entry in data.entries)
        if (!_isBlank(entry.value)) entry.key: entry.value,
    };
    if (sanitized.isEmpty) return;

    await _db.doc(FirestorePaths.userDoc(uid)).set(<String, dynamic>{
      ...sanitized,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    try {
      final snapshot = await _db.doc(FirestorePaths.userDoc(uid)).get();
      return snapshot.data();
    } catch (error) {
      debugPrint('Could not load profile: $error');
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // App config
  // -------------------------------------------------------------------------

  static Future<Map<String, dynamic>?> fetchAbout() async {
    try {
      final snapshot = await _db.doc(FirestorePaths.aboutDoc).get();
      return snapshot.data();
    } catch (error) {
      debugPrint('Could not load about information: $error');
      return null;
    }
  }

  static bool _isBlank(Object? value) =>
      value == null || (value is String && value.trim().isEmpty);
}
