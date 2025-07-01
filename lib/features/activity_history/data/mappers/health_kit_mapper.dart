import 'package:health_kit_reporter/model/payload/quantity.dart';
import 'package:health_kit_reporter/model/payload/workout.dart';
import 'package:health_kit_reporter/model/payload/workout_route.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';

import '../../domain/entities/cycling_workout_record.dart';
import '../../domain/entities/distance_data.dart';
import '../../domain/entities/heart_rate_data.dart';
import '../../domain/entities/location_data.dart';
import '../../domain/exceptions/health_kit_exceptions.dart';

class HealthKitMapper {
  /// Workout을 기본 정보만 포함한 CyclingWorkoutRecord로 변환 (심박수/거리 데이터 없음)
  static CyclingWorkoutRecord basicWorkoutRecord(Workout workout) {
    try {
      final double distanceKm =
          workout.harmonized.totalDistance?.toDouble() ?? 0.0;
      final double calories =
          workout.harmonized.totalEnergyBurned?.toDouble() ?? 0.0;

      // 킬로미터를 미터로 변환
      final double distanceM = distanceKm * 1000;

      return CyclingWorkoutRecord(
        id: workout.uuid,
        startTime: DateTime.fromMillisecondsSinceEpoch(
          (workout.startTimestamp * 1000).toInt(),
        ),
        endTime: DateTime.fromMillisecondsSinceEpoch(
          (workout.endTimestamp * 1000).toInt(),
        ),
        duration: Duration(seconds: workout.duration.toInt()),
        distance: distanceM, // 미터 단위로 저장
        calories: calories,
        heartRateData: <HeartRateData>[], // 빈 리스트로 시작
        distanceData: <DistanceData>[], // 빈 리스트로 시작
        locationData: <LocationData>[], // 빈 리스트로 시작
      );
    } catch (e) {
      throw HealthKitDataException('워크아웃 데이터 변환 실패: $e');
    }
  }

  /// 기존 CyclingWorkoutRecord에 심박수 데이터를 추가한 새로운 record 반환
  static CyclingWorkoutRecord addHeartRateData(
    CyclingWorkoutRecord record,
    List<HeartRateData> heartRateData,
  ) {
    return CyclingWorkoutRecord(
      id: record.id,
      startTime: record.startTime,
      endTime: record.endTime,
      duration: record.duration,
      distance: record.distance,
      calories: record.calories,
      heartRateData: heartRateData,
      distanceData: record.distanceData,
      locationData: record.locationData,
    );
  }

  /// 기존 CyclingWorkoutRecord에 거리 데이터를 추가한 새로운 record 반환
  static CyclingWorkoutRecord addDistanceData(
    CyclingWorkoutRecord record,
    List<DistanceData> distanceData,
  ) {
    return CyclingWorkoutRecord(
      id: record.id,
      startTime: record.startTime,
      endTime: record.endTime,
      duration: record.duration,
      distance: record.distance,
      calories: record.calories,
      heartRateData: record.heartRateData,
      distanceData: distanceData,
      locationData: record.locationData,
    );
  }

  /// 기존 CyclingWorkoutRecord에 GPS 위치 데이터를 추가한 새로운 record 반환
  static CyclingWorkoutRecord addLocationData(
    CyclingWorkoutRecord record,
    List<LocationData> locationData,
  ) {
    return CyclingWorkoutRecord(
      id: record.id,
      startTime: record.startTime,
      endTime: record.endTime,
      duration: record.duration,
      distance: record.distance,
      calories: record.calories,
      heartRateData: record.heartRateData,
      distanceData: record.distanceData,
      locationData: locationData,
    );
  }

  /// Quantity를 HeartRateData로 변환
  static HeartRateData toHeartRateData(Quantity quantity) {
    try {
      if (quantity.identifier != QuantityType.heartRate.identifier) {
        throw HealthKitDataException('HEART_RATE 타입이 아닌 데이터입니다');
      }

      return HeartRateData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          (quantity.startTimestamp * 1000).toInt(),
        ),
        heartRate: quantity.harmonized.value.round(),
      );
    } catch (e) {
      throw HealthKitDataException('심박수 데이터 변환 실패: $e');
    }
  }

  /// Quantity를 DistanceData로 변환
  static DistanceData toDistanceData(Quantity quantity) {
    try {
      if (quantity.identifier != QuantityType.distanceCycling.identifier) {
        throw HealthKitDataException('DISTANCE_CYCLING 타입이 아닌 데이터입니다');
      }

      final double distanceKm = quantity.harmonized.value.toDouble();
      final double distanceM = distanceKm * 1000; // 킬로미터를 미터로 변환

      return DistanceData(
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          (quantity.startTimestamp * 1000).toInt(),
        ),
        distance: distanceM, // 미터 단위로 저장
      );
    } catch (e) {
      throw HealthKitDataException('거리 데이터 변환 실패: $e');
    }
  }

  /// Quantity 리스트를 HeartRateData 리스트로 변환
  static List<HeartRateData> toHeartRateDataList(List<Quantity> quantities) {
    return quantities
        .map((Quantity quantity) => toHeartRateData(quantity))
        .toList();
  }

  /// Quantity 리스트를 DistanceData 리스트로 변환
  static List<DistanceData> toDistanceDataList(List<Quantity> quantities) {
    return quantities
        .map((Quantity quantity) => toDistanceData(quantity))
        .toList();
  }

  /// GPS 경로 데이터를 LocationData 리스트로 변환
  static List<LocationData> toLocationDataList(List<WorkoutRoute> routes) {
    try {
      if (routes.isEmpty) {
        return <LocationData>[];
      }

      final List<LocationData> locations = <LocationData>[];

      // 각 WorkoutRoute에서 경로 데이터 추출
      for (final WorkoutRoute route in routes) {
        // WorkoutRoute.harmonized.routes는 List<WorkoutRouteBatch>
        final List<dynamic> routeBatches = route.harmonized.routes;

        // 각 WorkoutRouteBatch 처리
        for (final dynamic batch in routeBatches) {
          // batch.locations는 List<LocationPoint>
          final List<dynamic> batchLocations = batch.locations;

          // 각 위치 정보를 LocationData로 변환
          for (final dynamic location in batchLocations) {
            try {
              final LocationData locationData = LocationData(
                timestamp: DateTime.fromMillisecondsSinceEpoch(
                  ((location.timestamp as num) * 1000).toInt(),
                ),
                latitude: (location.latitude as num).toDouble(),
                longitude: (location.longitude as num).toDouble(),
                altitude: (location.altitude as num?)?.toDouble(),
                speed: (location.speed as num?)?.toDouble(),
              );

              locations.add(locationData);
            } catch (e) {
              // 개별 위치 데이터 변환 실패 시에도 전체 프로세스 중단하지 않고 계속 진행
              continue;
            }
          }
        }
      }

      // 시간순으로 정렬
      locations.sort(
        (LocationData a, LocationData b) => a.timestamp.compareTo(b.timestamp),
      );

      return locations;
    } catch (e) {
      throw HealthKitDataException('GPS 경로 데이터 변환 실패: $e');
    }
  }
}
