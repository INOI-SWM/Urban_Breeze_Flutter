import '../../domain/entities/workout_statistics.dart';
import '../../domain/enums/statistic_enums.dart';
import '../../domain/repositories/workout_statistics_repository.dart';

class GetWorkoutStatisticsUseCase {
  const GetWorkoutStatisticsUseCase(this._repository);

  final WorkoutStatisticsRepository _repository;

  Future<WorkoutStatistics> execute({
    required StatisticPeriodType periodType,
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
