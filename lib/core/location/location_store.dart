import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../firestore/user_repository.dart';

/// The most recent position the app managed to resolve for this account.
class SavedLocation {
  const SavedLocation({
    required this.placeName,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.savedAt,
  });

  final String placeName;
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime? savedAt;

  /// A real fix needs both a position and a recorded save time. The fallback
  /// below has accuracy 0, so "no fix yet" is distinguishable from Kigali.
  bool get hasFix => accuracy > 0 && savedAt != null;

  /// Used before the first fix and after logout.
  static const SavedLocation fallback = SavedLocation(
    placeName: 'Rwanda',
    latitude: -1.9441,
    longitude: 30.0619,
    accuracy: 0,
  );

  static SavedLocation? fromMap(Map<String, dynamic> data) {
    final latitude = (data['latitude'] as num?)?.toDouble();
    final longitude = (data['longitude'] as num?)?.toDouble();
    if (latitude == null || longitude == null) return null;

    final name = (data['placeName'] as String?)?.trim() ?? '';
    final rawSavedAt = data['savedAt'];

    return SavedLocation(
      placeName: name.isEmpty ? 'Rwanda' : name,
      latitude: latitude,
      longitude: longitude,
      accuracy: (data['accuracy'] as num?)?.toDouble() ?? 0,
      savedAt: switch (rawSavedAt) {
        Timestamp timestamp => timestamp.toDate(),
        DateTime date => date,
        _ => null,
      },
    );
  }
}

/// In-memory cache in front of `users/{uid}.location`.
///
/// Screens read [cached] synchronously so the UI never waits on the network,
/// while [load] and [save] keep Firestore in sync in the background.
abstract final class LocationStore {
  static SavedLocation _cached = SavedLocation.fallback;

  static SavedLocation get cached => _cached;

  /// Restores the last saved location for the signed-in account.
  static Future<void> load() async {
    final uid = UserRepository.currentUid;
    if (uid == null) return;

    try {
      final data = await UserRepository.fetchLocation(uid);
      if (data == null) return;
      final parsed = SavedLocation.fromMap(data);
      if (parsed == null) return;
      _cached = parsed;
    } catch (error) {
      debugPrint('LocationStore.load failed: $error');
    }
  }

  /// Updates the cache first so the UI reacts immediately, then persists.
  ///
  /// Firestore failures are logged rather than thrown: a location write must
  /// never crash an emergency flow.
  static Future<void> save({
    required String placeName,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    _cached = SavedLocation(
      placeName: placeName,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      savedAt: DateTime.now(),
    );

    try {
      await UserRepository.saveLocation(
        placeName: placeName,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );
    } catch (error) {
      debugPrint('LocationStore.save failed: $error');
    }
  }

  /// Drops the cached fix so the next account starts fresh.
  static void clear() {
    _cached = SavedLocation.fallback;
  }
}
