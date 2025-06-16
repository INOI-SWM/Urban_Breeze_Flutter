import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_data.dart';

class PolylineUtils {
  static String encodeRouteSegments(List<RouteData> routeSegments) {
    if (routeSegments.isEmpty) return '';

    final List<List<num>> coordinates = <List<num>>[];
    for (final RouteData segment in routeSegments) {
      for (final LatLng point in segment.points) {
        coordinates.add(<double>[point.latitude, point.longitude]);
      }
    }

    return encodePolyline(coordinates);
  }

  static List<LatLng> decodeToPoints(String encodedPolyline) {
    if (encodedPolyline.isEmpty) return <LatLng>[];

    try {
      final List<List<num>> coordinates = decodePolyline(encodedPolyline);
      return coordinates
          .map(
            (List<num> coord) =>
                LatLng(coord[0].toDouble(), coord[1].toDouble()),
          )
          .toList();
    } catch (e) {
      return <LatLng>[];
    }
  }
}
