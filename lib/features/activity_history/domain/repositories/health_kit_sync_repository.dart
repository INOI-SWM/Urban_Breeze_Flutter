import 'package:ridingmate/features/activity_history/domain/entities/distance_data.dart';
import 'package:ridingmate/features/activity_history/domain/entities/heart_rate_data.dart';

import '../entities/cycling_workout_record.dart';

abstract class HealthKitSyncRepository {
  Future<bool> requestPermissions();
  Future<bool> hasPermissions();

  /// HealthKit에서 자전거 운동 데이터를 가져옵니다 (동기화용)
  Future<List<CyclingWorkoutRecord>> fetchCyclingWorkoutsFromHealthKit({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 특정 운동의 심박수 데이터를 가져옵니다
  Future<List<HeartRateData>> fetchHeartRateDataFromHealthKit({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  });

  /// 특정 운동의 거리 데이터를 가져옵니다
  Future<List<DistanceData>> fetchDistanceDataFromHealthKit({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  });
}
