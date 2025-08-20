import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_segment.dart';

enum RouteMode {
  drivingCar,
  cyclingRegular,
  cyclingRoad,
  cyclingMountain,
  cyclingElectric,
}

extension RouteModeExtension on RouteMode {
  String get apiValue {
    switch (this) {
      case RouteMode.drivingCar:
        return 'driving-car';
      case RouteMode.cyclingRegular:
        return 'cycling-regular';
      case RouteMode.cyclingRoad:
        return 'cycling-road';
      case RouteMode.cyclingMountain:
        return 'cycling-mountain';
      case RouteMode.cyclingElectric:
        return 'cycling-electric';
    }
  }
}

abstract class RouteSegmentRepository {
  Future<RouteSegment> getRouteSegment(
    LatLng start,
    LatLng end, {
    RouteMode mode = RouteMode.cyclingRoad,
  });
}
