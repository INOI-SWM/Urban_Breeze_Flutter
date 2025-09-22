import '../../domain/entities/workout_statistics.dart';
import '../../domain/enums/statistic_enums.dart';
import '../../domain/repositories/workout_statistics_repository.dart';
import '../../presentation/widgets/period_selector_dialog.dart';

class GetWorkoutStatisticsUseCase {
  const GetWorkoutStatisticsUseCase(this._repository);

  final WorkoutStatisticsRepository _repository;

  Future<WorkoutStatistics> execute({
    required StatisticPeriodType periodType,
    required PeriodSelection periodSelection,
  }) async {
    return await _repository.getWorkoutStatistics(
      periodType: periodType,
      year: periodSelection.year,
      month: periodSelection.month,
      week: periodSelection.week,
    );
  }
}
