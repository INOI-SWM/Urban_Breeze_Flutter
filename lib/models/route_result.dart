import 'package:latlong2/latlong.dart';

class RouteResult {
  RouteResult({
    required this.points,
    required this.distance,
    required this.duration,
    required this.ascent,
    required this.descent,
  });
  final List<LatLng> points;
  final double distance; // 미터
  final double duration; // 초
  final double ascent; // 총 상승고도(미터)
  final double descent; // 총 하강고도(미터)
}
