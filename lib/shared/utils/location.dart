import 'package:geolocator/geolocator.dart';

enum LocationPermissionStatus {
  allowed,
  denied,
  disabled,
  deniedForever
}

/// Requests the position Permission
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<LocationPermissionStatus> requestPositionPermission() async {
  bool serviceEnabled;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return LocationPermissionStatus.disabled;
  }

  LocationPermission permission;

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return LocationPermissionStatus.denied;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return LocationPermissionStatus.deniedForever;
  }

  return LocationPermissionStatus.allowed;
}

/// Determine the current position of the device.
Future<Position> determineCurrentPosition() async {

  return await Geolocator.getCurrentPosition();
}