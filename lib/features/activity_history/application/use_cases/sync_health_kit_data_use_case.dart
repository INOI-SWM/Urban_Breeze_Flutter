import '../../domain/entities/cycling_workout_record.dart';
import '../../domain/entities/distance_data.dart';
import '../../domain/entities/heart_rate_data.dart';
import '../../domain/repositories/health_kit_sync_repository.dart';

class SyncHealthKitDataUseCase {
  const SyncHealthKitDataUseCase(this._repository);
  final HealthKitSyncRepository _repository;

  Future<bool> requestPermissions() async {
    return await _repository.requestPermissions();
  }

  Future<bool> checkPermissions() async {
    return await _repository.hasPermissions();
  }

  /// 전체 운동 데이터 동기화 (운동 + 상세 데이터)
  Future<Map<CyclingWorkoutRecord, Map<String, dynamic>>>
  syncCompleteWorkoutData({DateTime? startDate, DateTime? endDate}) async {
    // 1. 운동 목록 가져오기
    final List<CyclingWorkoutRecord> workouts = await _repository
        .fetchCyclingWorkoutsFromHealthKit(
          startDate: startDate,
          endDate: endDate,
        );

    // 2. 각 운동의 상세 데이터 가져오기
    final Map<CyclingWorkoutRecord, Map<String, dynamic>> completeData =
        <CyclingWorkoutRecord, Map<String, dynamic>>{};

    for (final CyclingWorkoutRecord workout in workouts) {
      final List<HeartRateData> heartRateData = await _repository
          .fetchHeartRateDataFromHealthKit(
            workoutStartTime: workout.startTime,
            workoutEndTime: workout.endTime,
          );

      final List<DistanceData> distanceData = await _repository
          .fetchDistanceDataFromHealthKit(
            workoutStartTime: workout.startTime,
            workoutEndTime: workout.endTime,
          );

      completeData[workout] = <String, dynamic>{
        'heartRateData': heartRateData,
        'distanceData': distanceData,
      };
    }

    //TODO: 서버 저장

    return completeData;
  }
}
