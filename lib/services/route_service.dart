import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      final String apiKey = dotenv.env['OPENROUTE_API_KEY'] ?? '';
      final String startStr = '${start.longitude},${start.latitude}';
      final String endStr = '${end.longitude},${end.latitude}';

      final http.Response response = await http.get(
        Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=$startStr&end=$endStr',
        ),
        headers: <String, String>{
          'Accept':
              'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        debugPrint('ORS Response: $data');

        final List<List<dynamic>> coordinates =
            (data['features'][0]['geometry']['coordinates'] as List<dynamic>)
                .cast<List<dynamic>>();

        return coordinates
            .map(
              (List coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()),
            )
            .toList();
      }
      return <LatLng>[];
    } catch (e) {
      debugPrint('Error getting route: $e');
      return <LatLng>[];
    }
  }
}
