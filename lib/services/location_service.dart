import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Port of the geolocation usage from app.js:
/// navigator.geolocation.getCurrentPosition() calls
class LocationService {
  /// Check + request permission, then get current position.
  /// Port of the Promise wrapper around getCurrentPosition
  static Future<Position?> getCurrentPosition({bool highAccuracy = true}) async {
    // Check service
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // Check / request permission
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: highAccuracy ? LocationAccuracy.high : LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  /// Quick location grab for the new-request form (port of form submission geo)
  static Future<({double lat, double lng})?> getForRequest() async {
    final pos = await getCurrentPosition(highAccuracy: false);
    if (pos == null) return null;
    return (lat: pos.latitude, lng: pos.longitude);
  }

  /// Get location for chat "share location" button
  static Future<({double lat, double lng})?> getForChat() async {
    final pos = await getCurrentPosition(highAccuracy: true);
    if (pos == null) return null;
    return (lat: pos.latitude, lng: pos.longitude);
  }
}

/// Permission check helper (used before voice, location, camera)
class PermissionHelper {
  static Future<bool> microphone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> camera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> location() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> notification() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
