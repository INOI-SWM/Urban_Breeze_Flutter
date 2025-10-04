import 'package:urban_breeze/features/workout_history/domain/entities/activity_image.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/track_point.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_user.dart';
import 'package:urban_breeze/shared/utils/display_formatter.dart';
import 'package:urban_breeze/shared/utils/workout_formatter.dart';

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
    this.elevationGain,
    this.elevationLoss,
    this.cadence,
    this.averageHeartRate,
    this.maxHeartRate,
    this.averagePower,
    this.maxPower,
    this.calories,
    required this.user,
    required this.thumbnailImageUrl,
    required this.activityImages,
    required this.trackPointsCount,
    required this.trackPoints,
    required this.bbox,
  });

  final String id;
  final String title;
  final DateTime startedAt;
  final DateTime endedAt;
  final int activeDurationMinutes; // 초 단위
  final int totalDurationMinutes; // 초 단위
  final double distance; // m 단위 (API에서 미터로 받음)
  final double averageSpeed; // km/h
  final double? elevationGain; // m
  final double? elevationLoss; // m
  final int? cadence; // rpm
  final int? averageHeartRate; // bpm
  final int? maxHeartRate; // bpm
  final int? averagePower; // W
  final int? maxPower; // W
  final double? calories; // kcal
  final WorkoutUser user;
  final String thumbnailImageUrl;
  final List<ActivityImage> activityImages;
  final int trackPointsCount;
  final List<TrackPoint> trackPoints;
  final List<double> bbox; // [minLng, minLat, maxLng, maxLat]

  /// 총 운동 시간을 Duration으로 반환
  Duration get totalDuration => Duration(seconds: totalDurationMinutes);

  /// 활성 운동 시간을 Duration으로 반환
  Duration get activeDuration => Duration(seconds: activeDurationMinutes);

  /// 거리 표시용 문자열 반환 (미터 → km)
  String get distanceDisplay =>
      DisplayFormatter.formatDistanceFromMeters(distance);

  /// 평균 속도 표시용 문자열 반환
  String get averageSpeedDisplay => '${averageSpeed.toStringAsFixed(1)} km/h';

  /// 상승 고도 표시용 문자열 반환
  String get elevationGainDisplay =>
      elevationGain != null ? '${elevationGain!.round()} m' : '--';

  /// 하강 고도 표시용 문자열 반환
  String get elevationLossDisplay =>
      elevationLoss != null ? '${elevationLoss!.round()} m' : '--';

  /// 평균 심박수 표시용 문자열 반환
  String get averageHeartRateDisplay =>
      averageHeartRate != null ? '$averageHeartRate bpm' : '--';

  /// 최대 심박수 표시용 문자열 반환
  String get maxHeartRateDisplay =>
      maxHeartRate != null ? '$maxHeartRate bpm' : '--';

  /// 평균 파워 표시용 문자열 반환
  String get averagePowerDisplay =>
      averagePower != null ? '$averagePower W' : '--';

  /// 최대 파워 표시용 문자열 반환
  String get maxPowerDisplay => maxPower != null ? '$maxPower W' : '--';

  /// 케이던스 표시용 문자열 반환
  String get cadenceDisplay => cadence != null ? '$cadence rpm' : '--';

  /// 칼로리 표시용 문자열 반환
  String get caloriesDisplay =>
      calories != null ? '${calories!.round()} kcal' : '--';

  /// 데이터가 있는 필드들의 정보를 우선순위대로 반환
  List<Map<String, String>> get availableDataFields {
    final List<Map<String, String>> fields = <Map<String, String>>[];

    // 항상 표시되는 기본 필드들
    fields.add(<String, String>{
      'label': '운동 시간',
      'value': WorkoutFormatter.toDurationText(totalDuration),
    });
    fields.add(<String, String>{
      'label': '평균 속도',
      'value': averageSpeedDisplay,
    });

    // elevation gain은 거의 항상 있으므로 우선순위 높게
    if (elevationGain != null && elevationGain! > 0) {
      fields.add(<String, String>{
        'label': '상승고도',
        'value': elevationGainDisplay,
      });
    }

    // 칼로리는 있을 때만 표시
    if (calories != null && calories! > 0) {
      fields.add(<String, String>{'label': '소모 칼로리', 'value': caloriesDisplay});
    }

    // 심박수 데이터가 있는 경우
    if (averageHeartRate != null && averageHeartRate! > 0) {
      fields.add(<String, String>{
        'label': '평균 심박수',
        'value': averageHeartRateDisplay,
      });
    }

    if (maxHeartRate != null && maxHeartRate! > 0) {
      fields.add(<String, String>{
        'label': '최대 심박수',
        'value': maxHeartRateDisplay,
      });
    }

    // 케이던스 데이터가 있는 경우
    if (cadence != null && cadence! > 0) {
      fields.add(<String, String>{'label': '케이던스', 'value': cadenceDisplay});
    }

    if (averagePower != null && averagePower! > 0) {
      fields.add(<String, String>{
        'label': '평균 파워',
        'value': averagePowerDisplay,
      });
    }

    if (maxPower != null && maxPower! > 0) {
      fields.add(<String, String>{'label': '최대 파워', 'value': maxPowerDisplay});
    }

    return fields;
  }

  /// 특정 필드만 변경된 새로운 WorkoutDetail 객체 생성
  WorkoutDetail copyWith({
    String? id,
    String? title,
    DateTime? startedAt,
    DateTime? endedAt,
    int? activeDurationMinutes,
    int? totalDurationMinutes,
    double? distance,
    double? averageSpeed,
    double? elevationGain,
    double? elevationLoss,
    int? cadence,
    int? averageHeartRate,
    int? maxHeartRate,
    int? averagePower,
    int? maxPower,
    double? calories,
    WorkoutUser? user,
    String? thumbnailImageUrl,
    List<ActivityImage>? activityImages,
    int? trackPointsCount,
    List<TrackPoint>? trackPoints,
    List<double>? bbox,
  }) {
    return WorkoutDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      activeDurationMinutes:
          activeDurationMinutes ?? this.activeDurationMinutes,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      distance: distance ?? this.distance,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      cadence: cadence ?? this.cadence,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      averagePower: averagePower ?? this.averagePower,
      maxPower: maxPower ?? this.maxPower,
      calories: calories ?? this.calories,
      user: user ?? this.user,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      activityImages: activityImages ?? this.activityImages,
      trackPointsCount: trackPointsCount ?? this.trackPointsCount,
      trackPoints: trackPoints ?? this.trackPoints,
      bbox: bbox ?? this.bbox,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkoutDetail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'WorkoutDetail(id: $id, title: $title, distance: $distance m, duration: ${totalDurationMinutes}min)';
  }
}
