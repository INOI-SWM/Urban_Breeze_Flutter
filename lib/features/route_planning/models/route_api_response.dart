import 'package:latlong2/latlong.dart';

class RouteApiResponse {
  const RouteApiResponse({
    required this.points,
    required this.elevations,
    required this.distance,
    required this.duration,
    required this.rawAscent,
    required this.rawDescent,
  });

  final List<LatLng> points;
  final List<double> elevations;
  final double distance; // 단위 : 미터
  final double duration; // 단위 : 초
  final double rawAscent; // ORS 원시 총 상승고도(미터)
  final double rawDescent; // 총 하강고도(미터)
}
