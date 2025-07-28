import 'package:ridingmate/features/workout_history/data/models/workout_statistics_response_model.dart';

import '../../domain/entities/workout_statistics.dart';
import '../../domain/enums/statistic_enums.dart';
import '../../domain/repositories/workout_statistics_repository.dart';
import '../datasources/workout_statistics_datasource.dart';
import '../mappers/workout_statistics_mapper.dart';

class WorkoutStatisticsRepositoryImpl implements WorkoutStatisticsRepository {
  const WorkoutStatisticsRepositoryImpl(this._datasource);

  final WorkoutStatisticsDataSource _datasource;

  @override
  Future<WorkoutStatistics> getWorkoutStatistics({
    required StatisticPeriodType periodType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final WorkoutStatisticsResponseModel response = await _datasource
        .getWorkoutStatistics(
          periodType: periodType,
          startDate: startDate,
          endDate: endDate,
        );

    return WorkoutStatisticsMapper.toEntity(response);
  }
}
