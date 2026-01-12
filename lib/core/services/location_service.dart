import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Gets the user's current location as a readable string (e.g., "Portland, Oregon")
  /// Returns null if location is unavailable, permission denied, or any error occurs
  /// This is designed to be graceful - location is an optional enhancement
  static Future<String?> getCurrentLocationString() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled, return null gracefully
        return null;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permission denied, return null gracefully
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied, return null gracefully
        return null;
      }

      // Get current position with timeout
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low, // Use low accuracy to be faster and less battery intensive
          timeLimit: Duration(seconds: 10), // Timeout after 10 seconds
        ),
      );

      // Reverse geocode to get readable location
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      // Get the first placemark and format it
      Placemark place = placemarks.first;

      // Format as "City, State" or "City, Country" depending on what's available
      String? city = place.locality ?? place.subAdministrativeArea;
      String? region = place.administrativeArea ?? place.country;

      if (city != null && region != null) {
        return '$city, $region';
      } else if (city != null) {
        return city;
      } else if (region != null) {
        return region;
      }

      // If we can't get a readable location, return null gracefully
      return null;
    } catch (e) {
      // Any error (timeout, network, platform error, etc.) - return null gracefully
      // This ensures location is truly optional and doesn't break the app
      return null;
    }
  }
}
