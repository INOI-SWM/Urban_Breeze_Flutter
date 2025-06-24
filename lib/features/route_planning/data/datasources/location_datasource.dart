import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/domain/services/location_service.dart';

abstract class LocationDataSource {
  Future<bool> checkAndRequestPermission();
  Future<LatLng?> getCurrentLocation();
}

class GeolocatorLocationDataSource
    implements LocationDataSource, LocationService {
  @override
  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<LatLng?> getCurrentLocation() async {
    try {
      final bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      final Position position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      //todo : 위치정보 가져오는 중, 정말 의도치 않은 에러가 생겼을 때, 띄울 에러메시지 및 디자인 추가
      return null;
    }
  }
}
