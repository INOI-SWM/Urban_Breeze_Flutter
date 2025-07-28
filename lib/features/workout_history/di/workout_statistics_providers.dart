import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../application/use_cases/get_workout_statistics_use_case.dart';
import '../application/use_cases/update_workout_title_use_case.dart';
import '../data/datasources/remote_workout_history_datasource.dart';
import '../data/datasources/workout_statistics_datasource.dart';
import '../data/repositories/workout_history_repository_impl.dart';
import '../data/repositories/workout_statistics_repository_impl.dart';
import '../domain/repositories/workout_history_repository.dart';
import '../domain/repositories/workout_statistics_repository.dart';

// HTTP Client Provider
final Provider<http.Client> httpClientProvider = Provider<http.Client>((
  Ref<http.Client> ref,
) {
  final http.Client client = http.Client();
  ref.onDispose(() => client.close());
  return client;
});

// DataSource Providers
final Provider<WorkoutStatisticsDatasource>
workoutStatisticsDatasourceProvider = Provider<WorkoutStatisticsDatasource>((
  Ref<WorkoutStatisticsDatasource> ref,
) {
  return WorkoutStatisticsDatasource();
});

final Provider<RemoteWorkoutHistoryDatasource>
remoteWorkoutHistoryDatasourceProvider =
    Provider<RemoteWorkoutHistoryDatasource>((
      Ref<RemoteWorkoutHistoryDatasource> ref,
    ) {
      final http.Client client = ref.watch(httpClientProvider);
      final RemoteWorkoutHistoryDatasource dataSource =
          RemoteWorkoutHistoryDatasource(client: client);
      ref.onDispose(() => dataSource.dispose());
      return dataSource;
    });

// Repository Providers
final Provider<WorkoutStatisticsRepository>
workoutStatisticsRepositoryProvider = Provider<WorkoutStatisticsRepository>((
  Ref<WorkoutStatisticsRepository> ref,
) {
  final WorkoutStatisticsDatasource dataSource = ref.watch(
    workoutStatisticsDatasourceProvider,
  );

  return WorkoutStatisticsRepositoryImpl(dataSource);
});

final Provider<WorkoutHistoryRepository> workoutHistoryRepositoryProvider =
    Provider<WorkoutHistoryRepository>((Ref<WorkoutHistoryRepository> ref) {
      final RemoteWorkoutHistoryDatasource dataSource = ref.watch(
        remoteWorkoutHistoryDatasourceProvider,
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
