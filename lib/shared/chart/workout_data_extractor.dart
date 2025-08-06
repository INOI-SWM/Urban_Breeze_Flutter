import 'package:fl_chart/fl_chart.dart';
import 'package:ridingmate/features/workout_history/domain/entities/heart_rate_data.dart';
import 'package:ridingmate/features/workout_history/domain/entities/location_data.dart';
import 'package:ridingmate/features/workout_history/domain/entities/workout_record.dart';

class WorkoutDataExtractor {
  WorkoutDataExtractor._();

  /// 범용 시계열 데이터 추출기
  ///
  /// [data]: 추출할 데이터 리스트
  /// [timestampExtractor]: 타임스탬프 추출 함수
  /// [valueExtractor]: 값 추출 함수 (null 가능)
  /// [valueTransformer]: 값 변환 함수 (선택적)
  static List<FlSpot> extractTimeSeriesData<T>({
    required List<T> data,
    required DateTime Function(T) timestampExtractor,
    required double? Function(T) valueExtractor,
    double Function(double)? valueTransformer,
  }) {
    final List<FlSpot> spots = <FlSpot>[];

    if (data.isEmpty) return spots;

    final DateTime startTime = timestampExtractor(data.first);

    for (final T item in data) {
      final double? rawValue = valueExtractor(item);
      if (rawValue != null) {
        final double timeInMinutes =
            timestampExtractor(item).difference(startTime).inMilliseconds /
            (1000 * 60); // milliseconds to minutes

        final double finalValue = valueTransformer?.call(rawValue) ?? rawValue;
        spots.add(FlSpot(timeInMinutes, finalValue));
      }
    }

    return spots;
  }

  /// 속도 데이터 추출 (LocationData → FlSpot, m/s → km/h 변환)
  static List<FlSpot> extractSpeedData(WorkoutRecord workoutRecord) {
    return extractTimeSeriesData<LocationData>(
      data: workoutRecord.locationData ?? <LocationData>[],
      timestampExtractor: (LocationData location) => location.timestamp,
      valueExtractor: (LocationData location) => location.speed,
      valueTransformer: (double mPerSec) => mPerSec * 3.6, // m/s to km/h
    );
  }

  /// 고도 데이터 추출 (LocationData → FlSpot)
  static List<FlSpot> extractAltitudeData(WorkoutRecord workoutRecord) {
    return extractTimeSeriesData<LocationData>(
      data: workoutRecord.locationData ?? <LocationData>[],
      timestampExtractor: (LocationData location) => location.timestamp,
      valueExtractor: (LocationData location) => location.altitude,
    );
  }

  /// 심박수 데이터 추출 (HeartRateData → FlSpot)
  static List<FlSpot> extractHeartRateData(WorkoutRecord workoutRecord) {
    return extractTimeSeriesData<HeartRateData>(
      data: workoutRecord.heartRateData ?? <HeartRateData>[],
      timestampExtractor: (HeartRateData heartRate) => heartRate.timestamp,
      valueExtractor:
          (HeartRateData heartRate) => heartRate.heartRate.toDouble(),
    );
  }
}
