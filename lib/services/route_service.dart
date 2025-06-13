import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

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
  static String _buildRouteUrl(
    LatLng start,
    LatLng end, {
    RouteMode mode = RouteMode.cyclingRoad,
  }) {
    final String apiKey = dotenv.env['OPENROUTE_API_KEY'] ?? '';
    final String startStr = '${start.longitude},${start.latitude}';
    final String endStr = '${end.longitude},${end.latitude}';
    return 'https://api.openrouteservice.org/v2/directions/${mode.apiValue}?api_key=$apiKey&start=$startStr&end=$endStr';
  }

  static List<LatLng> _parseRouteResponse(Map<String, dynamic> data) {
    final List<List<dynamic>> coordinates =
        (data['features'][0]['geometry']['coordinates'] as List<dynamic>)
            .cast<List<dynamic>>();
    return coordinates
        .map(
          (List<dynamic> coord) =>
              LatLng(coord[1].toDouble(), coord[0].toDouble()),
        )
        .toList();
  }

  static Future<List<LatLng>> getRoute(
    LatLng start,
    LatLng end, {
    RouteMode mode = RouteMode.cyclingRoad,
  }) async {
    try {
      final String url = _buildRouteUrl(start, end, mode: mode);
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Accept':
              'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _parseRouteResponse(data);
      }
      return <LatLng>[];
    } catch (e) {
      return <LatLng>[];
    }
  }
}
