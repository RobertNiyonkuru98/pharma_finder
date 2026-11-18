import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


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
class LocationError extends LocationState{
    final String message;
    LocationError(this.message);

}

// Cubit State Management

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  // Function to get the current location of the user
  Future<void> getCurrentLocation() async {
    emit(LocationLoading());
    try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
        emit(LocationError('Location services are disabled.'));
        return;
    }

    // Check for location permissions in user's phone
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
            emit(LocationError('Location permissions are denied'));
            return;
        }
    }

// Handle the case where permissions are denied forever
    if (permission == LocationPermission.deniedForever) {
        emit(LocationError('Please enable location permissions in settings.'));
        return;
    }

    // Getting the GPS Coordinates
    Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
        ),
    );

    // Converting GPS Coordinates to a human-readable address
    String placeName = 'Rwanda';
    List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude, 
        position.longitude
        );

        if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            placeName = '${placemark.subLocality ?? placemark.locality ?? ''}, ${placemark.administrativeArea ?? 'Rwanda'}, ${placemark.country ?? ''}'.replaceAll(RegExp(r'^,\s*'), '');
        }
        
        emit(LocationLoaded(position: position, placeName: placeName));
  } catch (e) {
    emit(LocationError('Failed to get location: $e'));
  
  }
}
}