import 'package:fl_chart/fl_chart.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/track_point.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';

class WorkoutDataExtractor {
  WorkoutDataExtractor._();

  // ========== WorkoutDetail용 메서드들 ==========

  /// WorkoutDetail에서 고도 데이터 추출 (TrackPoint → FlSpot)
  /// index를 시간축으로 사용
  static List<FlSpot> extractAltitudeDataFromDetail(
    WorkoutDetail workoutDetail,
  ) {
    final List<TrackPoint> trackPoints =
        workoutDetail.trackPoints ?? <TrackPoint>[];

    if (trackPoints.isEmpty) return <FlSpot>[];

    return trackPoints.map((TrackPoint point) {
      return FlSpot(point.index.toDouble(), point.elevation);
    }).toList();
  }

  /// WorkoutDetail에서 속도 데이터 추출 (TrackPoint → FlSpot)
  /// index를 시간축으로 사용
  static List<FlSpot> extractSpeedDataFromDetail(WorkoutDetail workoutDetail) {
    final List<TrackPoint> trackPoints =
        workoutDetail.trackPoints ?? <TrackPoint>[];

    if (trackPoints.isEmpty) return <FlSpot>[];

    return trackPoints.where((TrackPoint point) => point.speed != null).map((
      TrackPoint point,
    ) {
      return FlSpot(point.index.toDouble(), point.speed!);
    }).toList();
  }

  /// WorkoutDetail에서 심박수 데이터 추출 (TrackPoint → FlSpot)
  /// index를 시간축으로 사용
  static List<FlSpot> extractHeartRateDataFromDetail(
    WorkoutDetail workoutDetail,
  ) {
    final List<TrackPoint> trackPoints =
        workoutDetail.trackPoints ?? <TrackPoint>[];

    if (trackPoints.isEmpty) return <FlSpot>[];

    return trackPoints.where((TrackPoint point) => point.heartRate != null).map(
      (TrackPoint point) {
        return FlSpot(point.index.toDouble(), point.heartRate!.toDouble());
      },
    ).toList();
  }
}
