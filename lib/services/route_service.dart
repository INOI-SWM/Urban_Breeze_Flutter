import 'package:latlong2/latlong.dart';

import '../models/route_api_response.dart';
import '../models/route_data.dart';
import 'elevation_calculator.dart';
import 'route_api_client.dart';

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

class RouteService {
  static Future<RouteData?> getRoute(
    LatLng start,
    LatLng end, {
    RouteMode mode = RouteMode.cyclingRoad,
  }) async {
    final RouteApiResponse? apiResponse = await RouteApiClient.fetchRoute(
      start,
      end,
      mode.apiValue,
    );

    if (apiResponse == null || !_isValidRouteData(apiResponse)) {
      return null;
    }

    final double elevationGain =
        ElevationCalculator.calculateSmoothedElevationGain(
          apiResponse.points,
          apiResponse.elevations,
        );

    return RouteData(
      points: apiResponse.points,
      distance: apiResponse.distance,
      duration: apiResponse.duration,
      ascent: apiResponse.rawAscent,
      descent: apiResponse.rawDescent,
      elevationGain: elevationGain,
    );
  }

  static bool _isValidRouteData(RouteApiResponse response) {
    if (response.points.length < 2) return false;
    if (response.distance < 0 || response.duration < 0) return false;
    if (response.points.length != response.elevations.length) return false;
    return true;
  }
}
