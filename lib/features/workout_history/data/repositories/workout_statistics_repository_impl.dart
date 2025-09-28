import 'package:urban_breeze/features/workout_history/data/models/workout_statistics_response_model.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

import '../../domain/entities/workout_statistics.dart';
import '../../domain/enums/statistic_enums.dart';
import '../../domain/repositories/workout_statistics_repository.dart';
import '../datasources/workout_statistics_datasource.dart';
import '../mappers/workout_statistics_mapper.dart';

class WorkoutStatisticsRepositoryImpl implements WorkoutStatisticsRepository {
  const WorkoutStatisticsRepositoryImpl(this._datasource);

  final RemoteWorkoutStatisticsDataSource _datasource;

  @override
  Future<WorkoutStatistics> getWorkoutStatistics({
    required StatisticPeriodType periodType,
    required int year,
    int? month,
    int? week,
  }) async {
    final ApiResponseModel<WorkoutStatisticsResponseModel> response =
        await _datasource.getWorkoutStatistics(
          periodType: periodType,
          year: year,
          month: month,
          week: week,
        );

    return WorkoutStatisticsMapper.toEntity(response.data);
  }
}
