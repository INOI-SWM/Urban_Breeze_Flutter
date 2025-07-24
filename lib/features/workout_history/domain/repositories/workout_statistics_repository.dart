import '../entities/workout_statistics.dart';

abstract class WorkoutStatisticsRepository {
  Future<WorkoutStatistics> getWorkoutStatistics({
    required String periodType, // "week", "month", "year", "all"
    DateTime? startDate,
    DateTime? endDate,
  });
}
