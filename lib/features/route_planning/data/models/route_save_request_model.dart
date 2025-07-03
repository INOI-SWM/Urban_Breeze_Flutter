/*
name: 경로 이름
polyline: Google Polyline 인코딩 형식
distance: 총 거리 (단위: 미터)
duration: 예상 소요 시간 (단위: 분)
elevationGain: 총 상승 고도 (단위: 미터)
 */

class RouteSaveRequestModel {
  const RouteSaveRequestModel({
    required this.name,
    required this.polyline,
    required this.distance,
    required this.duration,
    required this.elevationGain,
    required this.elevations,
    required this.bbox,
  });

  final String name;
  final String polyline;
  final double distance;
  final double duration;
  final double elevationGain;
  final List<double> elevations;
  final List<double> bbox;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': name,
      'polyline': polyline,
      'distance': distance,
      'duration': duration,
      'elevationGain': elevationGain,
    };
  }
}
