import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/models/route_api_response.dart';

class RouteApiClient {
  static final String _apiKey = dotenv.env['OPENROUTE_API_KEY'] ?? '';
  static final String _baseUrl = dotenv.env['ORS_BASE_URL'] ?? '';
  static const int _elevationIndex = 2;

  static Future<RouteApiResponse?> fetchRoute(
    LatLng start,
    LatLng end,
    String routeMode,
  ) async {
    try {
      final http.Response response = await _makeRouteRequest(
        start,
        end,
        routeMode,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body) as Map<String, dynamic>;
        return _parseApiResponse(data);
      }

      // TODO: 에러 상태 코드별 처리 추가
      return null;
    } catch (e) {
      // TODO: 구체적인 예외 처리 추가
      return null;
    }
  }

  static RouteApiResponse _parseApiResponse(Map<String, dynamic> data) {
    final List<List<dynamic>> coordinates =
        (data['features'][0]['geometry']['coordinates'] as List<dynamic>)
            .cast<List<dynamic>>();

    final ({List<double> elevations, List<LatLng> points}) routeData =
        _extractRouteData(coordinates);

    final Map<String, dynamic> properties =
        data['features'][0]['properties'] as Map<String, dynamic>;
    final Map<String, dynamic> summary =
        properties['summary'] as Map<String, dynamic>;

    return RouteApiResponse(
      points: routeData.points,
      elevations: routeData.elevations,
      distance: (summary['distance'] as num).toDouble(),
      duration: (summary['duration'] as num).toDouble(),
      rawAscent: (properties['ascent'] as num?)?.toDouble() ?? 0.0,
      rawDescent: (properties['descent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static ({List<LatLng> points, List<double> elevations}) _extractRouteData(
    List<List<dynamic>> coordinates,
  ) {
    final List<LatLng> points = <LatLng>[];
    final List<double> elevations = <double>[];

    for (final List<dynamic> coord in coordinates) {
      points.add(LatLng(coord[1].toDouble(), coord[0].toDouble()));

      elevations.add(
        coord.length > _elevationIndex
            ? (coord[_elevationIndex] as num).toDouble()
            : 0.0,
      );
    }

    return (points: points, elevations: elevations);
  }

  static Future<http.Response> _makeRouteRequest(
    LatLng start,
    LatLng end,
    String routeMode,
  ) {
    final String url = '$_baseUrl$routeMode/geojson';
    final Map<String, Object> body = <String, Object>{
      'coordinates': <List<double>>[
        <double>[start.longitude, start.latitude],
        <double>[end.longitude, end.latitude],
      ],
      'elevation': true,
    };

    return http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Accept':
            'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        'Authorization': _apiKey.isNotEmpty ? _apiKey : '',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: json.encode(body),
    );
  }
}
