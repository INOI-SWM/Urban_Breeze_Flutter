import 'package:latlong2/latlong.dart';

abstract class LocationService {
  Future<bool> checkAndRequestPermission();
  Future<LatLng?> getCurrentLocation();
}
