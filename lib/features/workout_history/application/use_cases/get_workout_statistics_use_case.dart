import '../../domain/entities/workout_statistics.dart';
import '../../domain/repositories/workout_statistics_repository.dart';

class GetWorkoutStatisticsUseCase {
  const GetWorkoutStatisticsUseCase(this._repository);

  final WorkoutStatisticsRepository _repository;

  /// 기간별 운동 통계 데이터 조회
  Future<WorkoutStatistics> execute({
    required String periodType, // "week", "month", "year", "all"
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _repository.getWorkoutStatistics(
      periodType: periodType,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
