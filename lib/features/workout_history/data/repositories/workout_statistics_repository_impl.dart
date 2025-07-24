import '../../domain/entities/workout_statistics.dart';
import '../../domain/repositories/workout_statistics_repository.dart';
import '../datasources/workout_statistics_datasource.dart';
import '../mappers/workout_statistics_mapper.dart';
import '../models/workout_statistics_response_model.dart';

class WorkoutStatisticsRepositoryImpl implements WorkoutStatisticsRepository {
  WorkoutStatisticsRepositoryImpl({WorkoutStatisticsDatasource? dataSource})
    : _dataSource = dataSource ?? WorkoutStatisticsDatasource();

  final WorkoutStatisticsDatasource _dataSource;

  @override
  Future<WorkoutStatistics> getWorkoutStatistics({
    required String periodType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final WorkoutStatisticsResponseModel model = await _dataSource
          .getWorkoutStatistics(
            periodType: periodType,
            startDate: startDate,
            endDate: endDate,
          );

      return WorkoutStatisticsMapper.toEntity(model);
    } catch (e) {
      // TODO: 적절한 domain exception으로 변환
      rethrow;
    }
  }
}
