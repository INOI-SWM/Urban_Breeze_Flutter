import 'package:latlong2/latlong.dart';

class RouteResult {
  RouteResult({
    required this.points,
    required this.distance,
    required this.duration,
  });
  final List<LatLng> points;
  final double distance; // 미터 단위
  final double duration; // 초 단위
}
