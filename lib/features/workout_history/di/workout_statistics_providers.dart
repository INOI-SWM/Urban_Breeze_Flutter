import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ridingmate/core/di/core_providers.dart';

import '../application/use_cases/get_workout_statistics_use_case.dart';
import '../application/use_cases/update_workout_title_use_case.dart';
import '../data/datasources/remote_workout_history_datasource.dart';
import '../data/datasources/workout_statistics_datasource.dart';
import '../data/repositories/workout_history_repository_impl.dart';
import '../data/repositories/workout_statistics_repository_impl.dart';
import '../domain/repositories/workout_history_repository.dart';
import '../domain/repositories/workout_statistics_repository.dart';

// Data Source Providers
final Provider<WorkoutStatisticsDataSource>
workoutStatisticsDataSourceProvider = Provider<WorkoutStatisticsDataSource>((
  Ref<WorkoutStatisticsDataSource> ref,
) {
  return WorkoutStatisticsDataSource();
});

final Provider<RemoteWorkoutHistoryDataSource>
remoteWorkoutHistoryDataSourceProvider =
    Provider<RemoteWorkoutHistoryDataSource>((
      Ref<RemoteWorkoutHistoryDataSource> ref,
    ) {
      final http.Client client = ref.watch(httpClientProvider);
      return RemoteWorkoutHistoryDataSource(client: client);
    });

// Repository Providers
final Provider<WorkoutStatisticsRepository>
workoutStatisticsRepositoryProvider = Provider<WorkoutStatisticsRepository>((
  Ref<WorkoutStatisticsRepository> ref,
) {
  final WorkoutStatisticsDataSource dataSource = ref.watch(
    workoutStatisticsDataSourceProvider,
  );

  return WorkoutStatisticsRepositoryImpl(dataSource);
});

final Provider<WorkoutHistoryRepository> workoutHistoryRepositoryProvider =
    Provider<WorkoutHistoryRepository>((Ref<WorkoutHistoryRepository> ref) {
      final RemoteWorkoutHistoryDataSource dataSource = ref.watch(
        remoteWorkoutHistoryDataSourceProvider,
      );

      return WorkoutHistoryRepositoryImpl(remoteDataSource: dataSource);
    });

// Use Case Providers
final Provider<GetWorkoutStatisticsUseCase>
getWorkoutStatisticsUseCaseProvider = Provider<GetWorkoutStatisticsUseCase>((
  Ref<GetWorkoutStatisticsUseCase> ref,
) {
  final WorkoutStatisticsRepository repository = ref.watch(
    workoutStatisticsRepositoryProvider,
  );

  return GetWorkoutStatisticsUseCase(repository);
});

final Provider<UpdateWorkoutTitleUseCase> updateWorkoutTitleUseCaseProvider =
    Provider<UpdateWorkoutTitleUseCase>((Ref<UpdateWorkoutTitleUseCase> ref) {
      final WorkoutHistoryRepository repository = ref.watch(
        workoutHistoryRepositoryProvider,
      );

      return UpdateWorkoutTitleUseCase(workoutHistoryRepository: repository);
    });
