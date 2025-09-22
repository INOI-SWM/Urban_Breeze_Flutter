import '../entities/workout_statistics.dart';
import '../enums/statistic_enums.dart';

abstract class WorkoutStatisticsRepository {
  Future<WorkoutStatistics> getWorkoutStatistics({
    required StatisticPeriodType periodType,
    required int year,
    int? month,
    int? week,
  });
}
