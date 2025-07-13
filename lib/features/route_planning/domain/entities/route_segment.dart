import 'package:latlong2/latlong.dart';

class RouteSegment {
  RouteSegment({
    required this.points,
    required this.elevations,
    required this.distance,
    required this.duration,
    required this.elevationGain,
    required this.bbox,
  });

  final List<LatLng> points;
  final List<double> elevations;
  final double distance; // 미터
  final int duration; // 분
  final double elevationGain; // Strava 스타일 의미있는 상승고도(미터)
  final List<double> bbox; //경로를 포함하는 경계 상자 [minLng, minLat, maxLng, maxLat]
}
