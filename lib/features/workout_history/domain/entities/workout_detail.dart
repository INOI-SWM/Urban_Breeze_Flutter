import 'package:urban_breeze/features/workout_history/domain/entities/activity_image.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/track_point.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_user.dart';

class WorkoutDetail {
  const WorkoutDetail({
    required this.id,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    required this.activeDurationMinutes,
    required this.totalDurationMinutes,
    required this.distance,
    required this.averageSpeed,
    required this.elevationGain,
    required this.elevationLoss,
    required this.cadence,
    required this.averageHeartRate,
    required this.maxHeartRate,
    required this.averagePower,
    required this.maxPower,
    required this.user,
    required this.thumbnailImageUrl,
    required this.activityImages,
    required this.trackPointsCount,
    required this.trackPoints,
    required this.bbox,
  });

  final int id;
  final String title;
  final DateTime startedAt;
  final DateTime endedAt;
  final int activeDurationMinutes; // 분 단위
  final int totalDurationMinutes; // 분 단위
  final double distance; // km 단위
  final double averageSpeed; // km/h
  final double elevationGain; // m
  final double elevationLoss; // m
  final int cadence; // rpm
  final int averageHeartRate; // bpm
  final int maxHeartRate; // bpm
  final int averagePower; // W
  final int maxPower; // W
  final WorkoutUser user;
  final String thumbnailImageUrl;
  final List<ActivityImage> activityImages;
  final int trackPointsCount;
  final List<TrackPoint> trackPoints;
  final List<double> bbox; // [minLng, minLat, maxLng, maxLat]

  /// 총 운동 시간을 Duration으로 반환
  Duration get totalDuration => Duration(minutes: totalDurationMinutes);

  /// 활성 운동 시간을 Duration으로 반환
  Duration get activeDuration => Duration(minutes: activeDurationMinutes);

  /// 거리 표시용 문자열 반환
  String get distanceDisplay => '${distance.toStringAsFixed(1)} km';

  /// 평균 속도 표시용 문자열 반환
  String get averageSpeedDisplay => '${averageSpeed.toStringAsFixed(1)} km/h';

  /// 상승 고도 표시용 문자열 반환
  String get elevationGainDisplay => '${elevationGain.round()} m';

  /// 하강 고도 표시용 문자열 반환
  String get elevationLossDisplay => '${elevationLoss.round()} m';

  /// 평균 심박수 표시용 문자열 반환
  String get averageHeartRateDisplay => '$averageHeartRate bpm';

  /// 최대 심박수 표시용 문자열 반환
  String get maxHeartRateDisplay => '$maxHeartRate bpm';

  /// 평균 파워 표시용 문자열 반환
  String get averagePowerDisplay => '$averagePower W';

  /// 최대 파워 표시용 문자열 반환
  String get maxPowerDisplay => '$maxPower W';

  /// 케이던스 표시용 문자열 반환
  String get cadenceDisplay => '$cadence rpm';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutDetail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WorkoutDetail(id: $id, title: $title, distance: $distance km, duration: ${totalDurationMinutes}min)';
  }
}
