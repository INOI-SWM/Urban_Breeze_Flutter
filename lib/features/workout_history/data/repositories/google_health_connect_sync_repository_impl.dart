import '../../domain/entities/distance_data.dart';
import '../../domain/entities/heart_rate_data.dart';
import '../../domain/entities/location_data.dart';
import '../../domain/entities/workout_record.dart';
import '../../domain/repositories/google_health_connect_sync_repository.dart';
import '../datasources/google_health_connect_datasource.dart';
import '../mappers/google_health_connect_mapper.dart';

class GoogleHealthConnectSyncRepositoryImpl
    implements GoogleHealthConnectSyncRepository {
  GoogleHealthConnectSyncRepositoryImpl({
    GoogleHealthConnectDataSource? dataSource,
  }) : _dataSource = dataSource ?? GoogleHealthConnectDataSource();
  final GoogleHealthConnectDataSource _dataSource;

  @override
  Future<bool> requestPermissions() async {
    return await _dataSource.requestPermissions();
  }

  @override
  Future<bool> hasPermissions() async {
    return await _dataSource.hasPermissions();
  }

  @override
  Future<List<WorkoutRecord>> fetchCyclingWorkoutsFromHealthConnect({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<Map<String, dynamic>> workouts = await _dataSource
        .getCyclingWorkouts(startDate: startDate, endDate: endDate);

    final List<WorkoutRecord> enrichedWorkouts = <WorkoutRecord>[];

    for (int i = 0; i < workouts.length; i++) {
      final Map<String, dynamic> workout = workouts[i];

      WorkoutRecord record = GoogleHealthConnectMapper.basicWorkoutRecord(
        workout,
      );

      final List<Future<dynamic>> futures = <Future<dynamic>>[
        _dataSource.getHeartRateDataForWorkout(
          workoutStartTime: record.startTime,
          workoutEndTime: record.endTime,
        ),
        _dataSource.getDistanceDataForWorkout(
          workoutStartTime: record.startTime,
          workoutEndTime: record.endTime,
        ),
        _dataSource.getLocationDataForSession(sessionId: record.id),
      ];

      final List<dynamic> results = await Future.wait(futures);

      final List<Map<String, dynamic>> heartRateData =
          results[0] as List<Map<String, dynamic>>;
      final List<Map<String, dynamic>> distanceData =
          results[1] as List<Map<String, dynamic>>;
      final List<Map<String, dynamic>> locationData =
          results[2] as List<Map<String, dynamic>>;

      final List<HeartRateData> heartRateDataList =
          GoogleHealthConnectMapper.toHeartRateDataList(heartRateData);
      final List<DistanceData> distanceDataList =
          GoogleHealthConnectMapper.toDistanceDataList(distanceData);
      final List<LocationData> locationDataList =
          GoogleHealthConnectMapper.toLocationDataList(locationData);

      // 거리와 칼로리 계산
      final double totalDistance = _calculateTotalDistance(distanceDataList);
      final double totalCalories = _calculateCalories(
        duration: record.duration,
        distance: totalDistance,
        averageHeartRate: _calculateAverageHeartRate(heartRateDataList),
      );

      record = record.copyWith(
        heartRateData: heartRateDataList,
        distanceData: distanceDataList,
        locationData: locationDataList,
      );

      // 거리와 칼로리를 포함한 완전한 WorkoutRecord 생성
      final WorkoutRecord completeRecord = WorkoutRecord(
        id: record.id,
        startTime: record.startTime,
        endTime: record.endTime,
        duration: record.duration,
        distance: totalDistance,
        calories: totalCalories,
        heartRateData: record.heartRateData,
        distanceData: record.distanceData,
        locationData: record.locationData,
      );

      enrichedWorkouts.add(completeRecord);
    }

    return enrichedWorkouts;
  }

  /// 총 거리 계산
  double _calculateTotalDistance(List<DistanceData> distanceDataList) {
    if (distanceDataList.isEmpty) return 0.0;

    double totalDistance = 0.0;
    for (final DistanceData data in distanceDataList) {
      totalDistance += data.distance;
    }
    return totalDistance;
  }

  /// 평균 심박수 계산
  double _calculateAverageHeartRate(List<HeartRateData> heartRateDataList) {
    if (heartRateDataList.isEmpty) return 0.0;

    double totalHeartRate = 0.0;
    for (final HeartRateData data in heartRateDataList) {
      totalHeartRate += data.heartRate;
    }
    return totalHeartRate / heartRateDataList.length;
  }

  /// 칼로리 계산 (간단한 공식)
  double _calculateCalories({
    required Duration duration,
    required double distance,
    required double averageHeartRate,
  }) {
    // 기본 칼로리 계산 공식 (자전거)
    // MET 값: 자전거 8.0 (중간 강도)
    // 체중: 70kg (기본값)
    const double weight = 70.0; // kg
    const double met = 8.0; // 자전거 MET 값

    final double hours = duration.inMinutes / 60.0;
    final double calories = met * weight * hours;

    return calories;
  }
}
