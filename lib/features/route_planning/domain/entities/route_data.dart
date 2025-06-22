import 'package:latlong2/latlong.dart';

class RouteData {
  RouteData({
    required this.points,
    required this.distance,
    required this.duration,
    required this.ascent,
    required this.descent,
    required this.elevationGain,
    this.bbox,
  });

  final List<LatLng> points;
  final double distance; // 미터
  final double duration; // 초
  final double ascent; // ORS 원시 총 상승고도(미터)
  final double descent; // 총 하강고도(미터)
  final double elevationGain; // Strava 스타일 의미있는 상승고도(미터)

  /// 경로를 포함하는 경계 상자 [minLng, minLat, maxLng, maxLat]
  final List<double>? bbox;
}
