import 'package:latlong2/latlong.dart';

abstract class LocationRepository {
  Future<bool> checkAndRequestPermission();
  Future<LatLng?> getCurrentLocation();
}
