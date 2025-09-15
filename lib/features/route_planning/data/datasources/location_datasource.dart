import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GeolocatorLocationDataSource {
  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<LatLng?> getCurrentLocation() async {
    try {
      final bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10미터 이상 이동 시 업데이트
      );

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
            '위치 정보를 가져오는데 실패하였습니다.',
            const Duration(seconds: 10),
          );
        },
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }
}
