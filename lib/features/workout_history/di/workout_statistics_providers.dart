import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/use_cases/get_workout_statistics_use_case.dart';
import '../data/datasources/workout_statistics_datasource.dart';
import '../data/repositories/workout_statistics_repository_impl.dart';
import '../domain/repositories/workout_statistics_repository.dart';

// DataSource Provider
final Provider<WorkoutStatisticsDatasource>
workoutStatisticsDatasourceProvider = Provider<WorkoutStatisticsDatasource>((
  Ref<WorkoutStatisticsDatasource> ref,
) {
  return WorkoutStatisticsDatasource();
});

// Repository Provider
final Provider<WorkoutStatisticsRepository>
workoutStatisticsRepositoryProvider = Provider<WorkoutStatisticsRepository>((
  Ref<WorkoutStatisticsRepository> ref,
) {
  final WorkoutStatisticsDatasource dataSource = ref.watch(
    workoutStatisticsDatasourceProvider,
  );

  return WorkoutStatisticsRepositoryImpl(dataSource);
});

// Use Case Provider
final Provider<GetWorkoutStatisticsUseCase>
getWorkoutStatisticsUseCaseProvider = Provider<GetWorkoutStatisticsUseCase>((
  Ref<GetWorkoutStatisticsUseCase> ref,
) {
  final WorkoutStatisticsRepository repository = ref.watch(
    workoutStatisticsRepositoryProvider,
  );

  return GetWorkoutStatisticsUseCase(repository);
});
