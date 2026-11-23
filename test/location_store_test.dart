import 'package:flutter_test/flutter_test.dart';
import 'package:pharma_finder/core/location/location_store.dart';

void main() {
  tearDown(LocationStore.clear);

  test('starts with a fallback that never reports a GPS fix', () {
    expect(LocationStore.cached.placeName, 'Rwanda');
    expect(LocationStore.cached.hasFix, isFalse);
  });

  test('save updates the cache immediately so the UI never waits', () async {
    await LocationStore.save(
      placeName: 'Kigali, Nyarugenge, Rwanda',
      latitude: -1.9536,
      longitude: 30.0605,
      accuracy: 8,
    );

    expect(LocationStore.cached.hasFix, isTrue);
    expect(LocationStore.cached.placeName, 'Kigali, Nyarugenge, Rwanda');
    expect(LocationStore.cached.accuracy, 8);
    expect(LocationStore.cached.savedAt, isNotNull);
  });

  test('clear drops the cached fix so the next account starts fresh', () async {
    await LocationStore.save(
      placeName: 'Kigali, Nyarugenge, Rwanda',
      latitude: -1.9536,
      longitude: 30.0605,
      accuracy: 8,
    );

    LocationStore.clear();

    expect(LocationStore.cached.hasFix, isFalse);
    expect(LocationStore.cached.placeName, 'Rwanda');
  });

  test('fromMap reads a stored location and rejects incomplete maps', () {
    final parsed = SavedLocation.fromMap(<String, dynamic>{
      'placeName': 'Kacyiru, Gasabo, Rwanda',
      'latitude': -1.9433,
      'longitude': 30.0895,
      'accuracy': 12,
      'savedAt': DateTime(2026, 11, 23),
    });

    expect(parsed, isNotNull);
    expect(parsed!.hasFix, isTrue);
    expect(parsed.placeName, 'Kacyiru, Gasabo, Rwanda');
    expect(parsed.latitude, -1.9433);

    expect(SavedLocation.fromMap(<String, dynamic>{'placeName': 'Kigali'}), isNull);
  });
}
