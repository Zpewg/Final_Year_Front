import 'location_service.dart';

class LocationServiceStub implements LocationService {

  @override
  Future<Map<String, double>?> getCurrentLocation() async {
    print("Location not supported on this platform");
    return null;
  }
}
LocationService getLocationService() => LocationServiceStub();