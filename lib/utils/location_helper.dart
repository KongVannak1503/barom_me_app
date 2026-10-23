import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}

class LocationHelper {
  LocationHelper._();

  // Several widgets ask for location at the same time on first launch; sharing
  // one permission request avoids Geolocator's "request already in progress".
  static Future<LocationPermission>? _pendingPermission;

  /// Checks the location service and permission (asking if needed), then
  /// returns the current position. Throws [LocationException] with a
  /// user-readable message when location can't be used.
  static Future<Position> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException('Location is turned off. Please enable location services.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      _pendingPermission ??= Geolocator.requestPermission()
          .whenComplete(() => _pendingPermission = null);
      permission = await _pendingPermission!;
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException('Location permission is required to clock in.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
          'Location permission is blocked. Please allow it in your phone settings.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      throw const LocationException('Could not get your location. Please try again.');
    }
  }
}
