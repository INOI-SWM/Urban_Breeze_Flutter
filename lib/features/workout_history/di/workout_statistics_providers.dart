import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';

import '../application/facades/terra_health_sync_facade.dart';
import '../application/use_cases/connect_terra_health_app_use_case.dart';
import '../application/use_cases/get_workout_statistics_use_case.dart';
import '../application/use_cases/initialize_terra_use_case.dart';
import '../application/use_cases/sync_apple_health_kit_data_use_case.dart';
import '../application/use_cases/sync_google_health_connect_data_use_case.dart';
import '../application/use_cases/sync_terra_health_data_use_case.dart';
import '../application/use_cases/update_workout_title_use_case.dart';
import '../data/datasources/google_health_connect_datasource.dart';
import '../data/datasources/remote_workout_history_datasource.dart';
import '../data/datasources/terra_api_datasoiurce.dart';
import '../data/datasources/workout_statistics_datasource.dart';
import '../data/repositories/apple_health_kit_sync_repository_impl.dart';
import '../data/repositories/google_health_connect_sync_repository_impl.dart';
import '../data/repositories/workout_history_repository_impl.dart';
import '../data/repositories/workout_statistics_repository_impl.dart';
import '../domain/repositories/google_health_connect_sync_repository.dart';
import '../domain/repositories/health_kit_sync_repository.dart';
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
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return RemoteWorkoutHistoryDataSource(client: client);
    });

final Provider<GoogleHealthConnectDataSource>
googleHealthConnectDataSourceProvider = Provider<GoogleHealthConnectDataSource>(
  (Ref<GoogleHealthConnectDataSource> ref) {
    return GoogleHealthConnectDataSource();
  },
);

// Terra API Data Source Provider
final Provider<TerraApiDataSource> terraApiDataSourceProvider =
    Provider<TerraApiDataSource>((Ref<TerraApiDataSource> ref) {
      return TerraApiDataSource(ref);
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
      final RemoteWorkoutHistoryDataSource remoteDataSource = ref.watch(
        remoteWorkoutHistoryDataSourceProvider,
      );

      return WorkoutHistoryRepositoryImpl(remoteDataSource: remoteDataSource);
    });

final Provider<HealthKitSyncRepository> healthKitSyncRepositoryProvider =
    Provider<HealthKitSyncRepository>((Ref<HealthKitSyncRepository> ref) {
      return AppleHealthKitSyncRepositoryImpl();
    });

final Provider<GoogleHealthConnectSyncRepository>
googleHealthConnectSyncRepositoryProvider =
    Provider<GoogleHealthConnectSyncRepository>((
      Ref<GoogleHealthConnectSyncRepository> ref,
    ) {
      final GoogleHealthConnectDataSource dataSource = ref.watch(
        googleHealthConnectDataSourceProvider,
      );

      return GoogleHealthConnectSyncRepositoryImpl(dataSource: dataSource);
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

final Provider<SyncAppleHealthKitDataUseCase>
syncAppleHealthKitDataUseCaseProvider = Provider<SyncAppleHealthKitDataUseCase>(
  (Ref<SyncAppleHealthKitDataUseCase> ref) {
    final HealthKitSyncRepository repository = ref.watch(
      healthKitSyncRepositoryProvider,
    );

    return SyncAppleHealthKitDataUseCase(repository);
  },
);

final Provider<SyncGoogleHealthConnectDataUseCase>
syncGoogleHealthConnectDataUseCaseProvider =
    Provider<SyncGoogleHealthConnectDataUseCase>((
      Ref<SyncGoogleHealthConnectDataUseCase> ref,
    ) {
      final GoogleHealthConnectSyncRepository repository = ref.watch(
        googleHealthConnectSyncRepositoryProvider,
      );

      return SyncGoogleHealthConnectDataUseCase(repository);
    });

// Terra Use Case Providers
final Provider<InitializeTerraUseCase> initializeTerraUseCaseProvider =
    Provider<InitializeTerraUseCase>((Ref<InitializeTerraUseCase> ref) {
      final TerraApiDataSource terraDataSource = ref.watch(
        terraApiDataSourceProvider,
      );
      return InitializeTerraUseCase(terraDataSource: terraDataSource);
    });

final Provider<ConnectTerraHealthAppUseCase>
connectTerraHealthAppUseCaseProvider = Provider<ConnectTerraHealthAppUseCase>((
  Ref<ConnectTerraHealthAppUseCase> ref,
) {
  final TerraApiDataSource terraDataSource = ref.watch(
    terraApiDataSourceProvider,
  );
  return ConnectTerraHealthAppUseCase(terraDataSource: terraDataSource);
});

final Provider<SyncTerraHealthDataUseCase> syncTerraHealthDataUseCaseProvider =
    Provider<SyncTerraHealthDataUseCase>((Ref<SyncTerraHealthDataUseCase> ref) {
      final TerraApiDataSource terraDataSource = ref.watch(
        terraApiDataSourceProvider,
      );
      return SyncTerraHealthDataUseCase(terraDataSource: terraDataSource);
    });

// Terra Facade Provider
final Provider<TerraHealthSyncFacade> terraHealthSyncFacadeProvider =
    Provider<TerraHealthSyncFacade>((Ref<TerraHealthSyncFacade> ref) {
      final InitializeTerraUseCase initializeTerraUseCase = ref.watch(
        initializeTerraUseCaseProvider,
      );
      final ConnectTerraHealthAppUseCase connectTerraHealthAppUseCase = ref
          .watch(connectTerraHealthAppUseCaseProvider);
      final SyncTerraHealthDataUseCase syncTerraHealthDataUseCase = ref.watch(
        syncTerraHealthDataUseCaseProvider,
      );

      return TerraHealthSyncFacade(
        initializeTerraUseCase: initializeTerraUseCase,
        connectTerraHealthAppUseCase: connectTerraHealthAppUseCase,
        syncTerraHealthDataUseCase: syncTerraHealthDataUseCase,
      );
    });
