import 'dart:html' as html;
import 'location_service.dart';

class LocationServiceWeb implements LocationService {

  @override
  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      final position =
          await html.window.navigator.geolocation.getCurrentPosition();

      final lat = position.coords?.latitude?.toDouble();
      final lng = position.coords?.longitude?.toDouble();

      if (lat == null || lng == null) return null;

      return {
        "lat": lat,
        "lng": lng,
      };
    } catch (e) {
      print("GPS error: $e");
      return null;
    }
  }
}
LocationService getLocationService() => LocationServiceWeb();