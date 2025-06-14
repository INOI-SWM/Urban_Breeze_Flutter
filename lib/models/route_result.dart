import 'package:latlong2/latlong.dart';

class RouteResult {
  RouteResult({
    required this.points,
    required this.distance,
    required this.duration,
    required this.ascent,
    required this.descent,
    required this.elevationGain,
  });
  final List<LatLng> points;
  final double distance; // 단위: 미터
  final double duration; // 단위: 초
  final double ascent; // ORS 원시 총 상승고도(미터)
  final double descent; // 총 하강고도(미터)
  final double elevationGain; //의미있는 상승고도(미터)
}
