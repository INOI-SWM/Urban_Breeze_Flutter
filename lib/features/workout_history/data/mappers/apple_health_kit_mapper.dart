import 'package:flutter/foundation.dart';
import 'package:health_kit_reporter/model/payload/quantity.dart';
import 'package:health_kit_reporter/model/payload/workout.dart';
import 'package:health_kit_reporter/model/payload/workout_route.dart';
import 'package:health_kit_reporter/model/type/quantity_type.dart';

import '../../domain/entities/distance_data.dart';
import '../../domain/entities/heart_rate_data.dart';
import '../../domain/entities/location_data.dart';
import '../../domain/entities/workout_record.dart';
import '../../domain/exceptions/apple_health_kit_exceptions.dart';

/// HealthKit 타임스탬프 변환 유틸리티
class AppleHealthKitTimestampUtils {
  /// HealthKit timestamp (초 단위)를 Flutter DateTime으로 변환
  static DateTime fromHealthKitTimestamp(num timestamp) {
    return DateTime.fromMillisecondsSinceEpoch((timestamp * 1000).toInt());
  }
}

class AppleHealthKitMapper {
  /// Workout을 기본 정보만 포함한 CyclingWorkoutRecord로 변환 (심박수/거리 데이터 없음)
  static WorkoutRecord basicWorkoutRecord(Workout workout) {
    try {
      final double distance =
          workout.harmonized.totalDistance?.toDouble() ?? 0.0;
      final double calories =
          workout.harmonized.totalEnergyBurned?.toDouble() ?? 0.0;

      debugPrint('distance: $distance');
      debugPrint('calories: $calories');

      return WorkoutRecord(
        id: workout.uuid,
        startTime: AppleHealthKitTimestampUtils.fromHealthKitTimestamp(
          workout.startTimestamp,
        ),
        endTime: AppleHealthKitTimestampUtils.fromHealthKitTimestamp(
          workout.endTimestamp,
        ),
        duration: Duration(seconds: workout.duration.toInt()),
        distance: distance, // 미터 단위로 저장
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
  static WorkoutRecord addHeartRateData(
    WorkoutRecord record,
    List<HeartRateData> heartRateData,
  ) {
    return record.copyWith(heartRateData: heartRateData);
  }

  /// 기존 CyclingWorkoutRecord에 거리 데이터를 추가한 새로운 record 반환
  static WorkoutRecord addDistanceData(
    WorkoutRecord record,
    List<DistanceData> distanceData,
  ) {
    return record.copyWith(distanceData: distanceData);
  }

  /// 기존 CyclingWorkoutRecord에 GPS 위치 데이터를 추가한 새로운 record 반환
  static WorkoutRecord addLocationData(
    WorkoutRecord record,
    List<LocationData> locationData,
  ) {
    return record.copyWith(locationData: locationData);
  }

  /// Quantity를 HeartRateData로 변환
  static HeartRateData toHeartRateData(Quantity quantity) {
    try {
      if (quantity.identifier != QuantityType.heartRate.identifier) {
        throw const HealthKitDataException('HEART_RATE 타입이 아닌 데이터입니다');
      }

      return HeartRateData(
        timestamp: AppleHealthKitTimestampUtils.fromHealthKitTimestamp(
          quantity.startTimestamp,
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
        throw const HealthKitDataException('DISTANCE_CYCLING 타입이 아닌 데이터입니다');
      }

      final double distance = quantity.harmonized.value.toDouble();
      return DistanceData(
        timestamp: AppleHealthKitTimestampUtils.fromHealthKitTimestamp(
          quantity.startTimestamp,
        ),
        distance: distance,
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
                timestamp: AppleHealthKitTimestampUtils.fromHealthKitTimestamp(
                  location.timestamp,
                ),
                latitude: (location.latitude as num).toDouble(),
                longitude: (location.longitude as num).toDouble(),
                altitude: (location.altitude as num?)?.toDouble(),
                speed: (location.speed as num?)?.toDouble(),
                horizontalAccuracy:
                    (location.horizontalAccuracy as num?)?.toDouble(),
                verticalAccuracy:
                    (location.verticalAccuracy as num?)?.toDouble(),
                course: (location.course as num?)?.toDouble(),
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
