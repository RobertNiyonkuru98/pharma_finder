import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../core/location/location_store.dart';

// Main States
abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final Position position;
  final String placeName;
  LocationLoaded({required this.position, required this.placeName});
}

// Error Handling States
class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}

// Cubit State Management

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  StreamSubscription<Position>? _posSub;

  // ── NEW: request permission and stream continuous position updates ──
  Future<void> requestAndStreamLocation() async {
    emit(LocationLoading());
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationError('Location services are disabled.'));
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        emit(LocationError('Location permissions are denied'));
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        emit(LocationError('Please enable location permissions in settings.'));
        return;
      }

      // Seed one fix up front so the UI has something to show even when the
      // stream takes a while to deliver its first update.
      try {
        final first = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
        final firstName = await _resolvePlaceName(first);
        await LocationStore.save(
          placeName: firstName,
          latitude: first.latitude,
          longitude: first.longitude,
          accuracy: first.accuracy,
        );
        if (!isClosed) {
          emit(LocationLoaded(position: first, placeName: firstName));
        }
      } catch (error) {
        debugPrint('Initial location fix failed: $error');
      }

      // Kick off the stream. Each fix updates state → BlocBuilder re-renders.
      await _posSub?.cancel();
      _posSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10, // metres — ignore tiny jitter
            ),
          ).listen((pos) async {
            final name = await _resolvePlaceName(pos);
            await LocationStore.save(
              placeName: name,
              latitude: pos.latitude,
              longitude: pos.longitude,
              accuracy: pos.accuracy,
            );
            if (isClosed) return;
            emit(LocationLoaded(position: pos, placeName: name));
          }, onError: (e) => emit(LocationError('Stream error: $e')));
    } catch (e) {
      emit(LocationError('Failed to get location: $e'));
    }
  }

  // ── NEW: stop the stream when the screen is left ──
  Future<void> stopTracking() async {
    await _posSub?.cancel();
    _posSub = null;
  }

  // ── Existing helper, reused ──
  Future<String> _resolvePlaceName(Position position) async {
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return 'Rwanda';
      final p = placemarks.first;
      return '${p.subLocality ?? p.locality ?? ''}, '
              '${p.administrativeArea ?? 'Rwanda'}, '
              '${p.country ?? ''}'
          .replaceAll(RegExp(r'^,\s*'), '');
    } catch (_) {
      return 'Rwanda';
    }
  }

  Future<void> loadIfPermitted() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      await requestAndStreamLocation();
    } else {
      emit(LocationInitial());
    }
  }

  Future<void> getCurrentLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      await requestAndStreamLocation(); // already granted → no dialog
    } else {
      await requestAndStreamLocation(); // taps are explicit → OK to prompt
    }
  }

  @override
  Future<void> close() async {
    await _posSub?.cancel();
    return super.close();
  }
}
