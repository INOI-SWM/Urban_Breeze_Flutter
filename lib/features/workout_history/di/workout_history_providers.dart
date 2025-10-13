import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';
import 'package:urban_breeze/features/integration/application/facades/integration_sync_facade.dart';
import 'package:urban_breeze/features/integration/application/use_cases/get_integration_status_use_case.dart';
import 'package:urban_breeze/features/integration/di/integration_providers.dart';

import '../application/facades/terra_health_sync_facade.dart';
import '../application/facades/workout_refresh_facade.dart';
import '../application/facades/workout_sync_facade.dart';
import '../application/use_cases/connect_apple_health_use_case.dart';
import '../application/use_cases/connect_terra_health_app_use_case.dart';
import '../application/use_cases/delete_workout_image_use_case.dart';
import '../application/use_cases/delete_workout_use_case.dart';
import '../application/use_cases/get_workout_detail_use_case.dart';
import '../application/use_cases/get_workout_list_use_case.dart';
import '../application/use_cases/get_workout_statistics_use_case.dart';
import '../application/use_cases/import_apple_health_workouts_use_case.dart';
import '../application/use_cases/initialize_terra_use_case.dart';
import '../application/use_cases/selective_sync_use_case.dart';
import '../application/use_cases/sync_apple_health_kit_data_use_case.dart';
import '../application/use_cases/sync_google_health_connect_data_use_case.dart';
import '../application/use_cases/sync_terra_health_data_use_case.dart';
import '../application/use_cases/update_workout_title_use_case.dart';
import '../application/use_cases/upload_workout_images_use_case.dart';
import '../data/datasources/apple_health_connect_datasource.dart';
import '../data/datasources/apple_health_workout_datasource.dart';
import '../data/datasources/google_health_connect_datasource.dart';
import '../data/datasources/remote_workout_history_datasource.dart';
import '../data/datasources/terra_api_datasoiurce.dart';
import '../data/datasources/workout_statistics_datasource.dart';
import '../data/repositories/apple_health_connect_repository_impl.dart';
import '../data/repositories/apple_health_kit_sync_repository_impl.dart';
import '../data/repositories/google_health_connect_sync_repository_impl.dart';
import '../data/repositories/terra_repository_impl.dart';
import '../data/repositories/workout_history_repository_impl.dart';
import '../data/repositories/workout_statistics_repository_impl.dart';
import '../domain/repositories/apple_health_connect_repository.dart';
import '../domain/repositories/google_health_connect_sync_repository.dart';
import '../domain/repositories/health_kit_sync_repository.dart';
import '../domain/repositories/terra_repository.dart';
import '../domain/repositories/workout_history_repository.dart';
import '../domain/repositories/workout_statistics_repository.dart';
import '../presentation/notifiers/sync_screen_notifier.dart';
import '../presentation/notifiers/workout_refresh_notifier.dart';

// Data Source Providers
final Provider<RemoteWorkoutStatisticsDataSource>
remoteWorkoutStatisticsDataSourceProvider =
    Provider<RemoteWorkoutStatisticsDataSource>((
      Ref<RemoteWorkoutStatisticsDataSource> ref,
    ) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return RemoteWorkoutStatisticsDataSource(client: client);
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
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return TerraApiDataSource(client: client, ref: ref);
    });

// Apple Health Connect Data Source Provider
final Provider<AppleHealthConnectDataSource>
appleHealthConnectDataSourceProvider = Provider<AppleHealthConnectDataSource>((
  Ref<AppleHealthConnectDataSource> ref,
) {
  final http.Client client = ref.watch(authorizedHttpClientProvider);
  return AppleHealthConnectDataSource(client: client);
});

// Repository Providers
final Provider<WorkoutStatisticsRepository>
workoutStatisticsRepositoryProvider = Provider<WorkoutStatisticsRepository>((
  Ref<WorkoutStatisticsRepository> ref,
) {
  final RemoteWorkoutStatisticsDataSource dataSource = ref.watch(
    remoteWorkoutStatisticsDataSourceProvider,
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

final Provider<AppleHealthConnectRepository>
appleHealthConnectRepositoryProvider = Provider<AppleHealthConnectRepository>((
  Ref<AppleHealthConnectRepository> ref,
) {
  final AppleHealthConnectDataSource dataSource = ref.watch(
    appleHealthConnectDataSourceProvider,
  );
  return AppleHealthConnectRepositoryImpl(dataSource: dataSource);
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

final Provider<GetWorkoutListUseCase> getWorkoutListUseCaseProvider =
    Provider<GetWorkoutListUseCase>((Ref<GetWorkoutListUseCase> ref) {
      final WorkoutHistoryRepository repository = ref.watch(
        workoutHistoryRepositoryProvider,
      );

      return GetWorkoutListUseCase(repository: repository);
    });

final Provider<GetWorkoutDetailUseCase> getWorkoutDetailUseCaseProvider =
    Provider<GetWorkoutDetailUseCase>((Ref<GetWorkoutDetailUseCase> ref) {
      final WorkoutHistoryRepository repository = ref.watch(
        workoutHistoryRepositoryProvider,
      );

      return GetWorkoutDetailUseCase(repository: repository);
    });

final Provider<UpdateWorkoutTitleUseCase> updateWorkoutTitleUseCaseProvider =
    Provider<UpdateWorkoutTitleUseCase>((Ref<UpdateWorkoutTitleUseCase> ref) {
      final WorkoutHistoryRepository repository = ref.watch(
        workoutHistoryRepositoryProvider,
      );

      return UpdateWorkoutTitleUseCase(repository: repository);
    });

final Provider<UploadWorkoutImagesUseCase> uploadWorkoutImagesUseCaseProvider =
    Provider<UploadWorkoutImagesUseCase>((Ref<UploadWorkoutImagesUseCase> ref) {
      final WorkoutHistoryRepository repository = ref.watch(
        workoutHistoryRepositoryProvider,
      );

      return UploadWorkoutImagesUseCase(repository: repository);
    });

final Provider<DeleteWorkoutImageUseCase> deleteWorkoutImageUseCaseProvider =
    Provider<DeleteWorkoutImageUseCase>((Ref<DeleteWorkoutImageUseCase> ref) {
      final WorkoutHistoryRepository repository = ref.watch(
        workoutHistoryRepositoryProvider,
      );
      return DeleteWorkoutImageUseCase(repository: repository);
    });

final Provider<DeleteWorkoutUseCase> deleteWorkoutUseCaseProvider =
    Provider<DeleteWorkoutUseCase>((Ref<DeleteWorkoutUseCase> ref) {
      final WorkoutHistoryRepository repository = ref.watch(
        workoutHistoryRepositoryProvider,
      );
      return DeleteWorkoutUseCase(repository: repository);
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

final Provider<ConnectAppleHealthUseCase> connectAppleHealthUseCaseProvider =
    Provider<ConnectAppleHealthUseCase>((Ref<ConnectAppleHealthUseCase> ref) {
      final AppleHealthConnectRepository repository = ref.watch(
        appleHealthConnectRepositoryProvider,
      );
      return ConnectAppleHealthUseCase(repository: repository);
    });

// Terra Repository Provider
final Provider<TerraRepository> terraRepositoryProvider =
    Provider<TerraRepository>((Ref<TerraRepository> ref) {
      final TerraApiDataSource dataSource = ref.watch(
        terraApiDataSourceProvider,
      );
      return TerraRepositoryImpl(dataSource: dataSource);
    });

// Terra Use Case Providers
final Provider<InitializeTerraUseCase> initializeTerraUseCaseProvider =
    Provider<InitializeTerraUseCase>((Ref<InitializeTerraUseCase> ref) {
      final TerraRepository repository = ref.watch(terraRepositoryProvider);
      return InitializeTerraUseCase(repository: repository);
    });

final Provider<ConnectTerraHealthAppUseCase>
connectTerraHealthAppUseCaseProvider = Provider<ConnectTerraHealthAppUseCase>((
  Ref<ConnectTerraHealthAppUseCase> ref,
) {
  final TerraRepository repository = ref.watch(terraRepositoryProvider);
  return ConnectTerraHealthAppUseCase(repository: repository);
});

final Provider<SyncTerraHealthDataUseCase> syncTerraHealthDataUseCaseProvider =
    Provider<SyncTerraHealthDataUseCase>((Ref<SyncTerraHealthDataUseCase> ref) {
      final TerraRepository repository = ref.watch(terraRepositoryProvider);
      return SyncTerraHealthDataUseCase(repository: repository);
    });

// Apple Health Workout Data Source Provider
final Provider<AppleHealthWorkoutDataSource>
appleHealthWorkoutDataSourceProvider = Provider<AppleHealthWorkoutDataSource>((
  Ref<AppleHealthWorkoutDataSource> ref,
) {
  final http.Client client = ref.watch(authorizedHttpClientProvider);
  return AppleHealthWorkoutDataSource(client: client);
});

final Provider<ImportAppleHealthWorkoutsUseCase>
importAppleHealthWorkoutsUseCaseProvider =
    Provider<ImportAppleHealthWorkoutsUseCase>((
      Ref<ImportAppleHealthWorkoutsUseCase> ref,
    ) {
      final AppleHealthWorkoutDataSource appleHealthWorkoutDataSource = ref
          .watch(appleHealthWorkoutDataSourceProvider);
      return ImportAppleHealthWorkoutsUseCase(
        appleHealthWorkoutDataSource: appleHealthWorkoutDataSource,
      );
    });

// Terra Facade Provider
final Provider<TerraHealthSyncFacade> terraHealthSyncFacadeProvider = Provider<
  TerraHealthSyncFacade
>((Ref<TerraHealthSyncFacade> ref) {
  final InitializeTerraUseCase initializeTerraUseCase = ref.watch(
    initializeTerraUseCaseProvider,
  );
  final ConnectTerraHealthAppUseCase connectTerraHealthAppUseCase = ref.watch(
    connectTerraHealthAppUseCaseProvider,
  );
  final SyncTerraHealthDataUseCase syncTerraHealthDataUseCase = ref.watch(
    syncTerraHealthDataUseCaseProvider,
  );
  final SyncGoogleHealthConnectDataUseCase syncGoogleHealthConnectDataUseCase =
      ref.watch(syncGoogleHealthConnectDataUseCaseProvider);

  return TerraHealthSyncFacade(
    initializeTerraUseCase: initializeTerraUseCase,
    connectTerraHealthAppUseCase: connectTerraHealthAppUseCase,
    syncTerraHealthDataUseCase: syncTerraHealthDataUseCase,
    syncGoogleHealthConnectDataUseCase: syncGoogleHealthConnectDataUseCase,
  );
});

// Workout Sync Facade Provider (통합 Facade)
final Provider<WorkoutSyncFacade>
workoutSyncFacadeProvider = Provider<WorkoutSyncFacade>((Ref ref) {
  final TerraHealthSyncFacade terraHealthSyncFacade = ref.watch(
    terraHealthSyncFacadeProvider,
  );
  final IntegrationSyncFacade integrationSyncFacade = ref.watch(
    integrationSyncFacadeProvider,
  );
  final SyncAppleHealthKitDataUseCase syncAppleHealthKitDataUseCase = ref.watch(
    syncAppleHealthKitDataUseCaseProvider,
  );
  final SyncGoogleHealthConnectDataUseCase syncGoogleHealthConnectDataUseCase =
      ref.watch(syncGoogleHealthConnectDataUseCaseProvider);
  final ImportAppleHealthWorkoutsUseCase importAppleHealthWorkoutsUseCase = ref
      .watch(importAppleHealthWorkoutsUseCaseProvider);
  final GetIntegrationStatusUseCase getIntegrationStatusUseCase = ref.watch(
    getIntegrationStatusUseCaseProvider,
  );

  return WorkoutSyncFacade(
    terraHealthSyncFacade: terraHealthSyncFacade,
    integrationSyncFacade: integrationSyncFacade,
    syncAppleHealthKitDataUseCase: syncAppleHealthKitDataUseCase,
    syncGoogleHealthConnectDataUseCase: syncGoogleHealthConnectDataUseCase,
    importAppleHealthWorkoutsUseCase: importAppleHealthWorkoutsUseCase,
    getIntegrationStatusUseCase: getIntegrationStatusUseCase,
  );
});

// SyncScreenNotifier Provider
final StateNotifierProvider<SyncScreenNotifier, SyncScreenState>
syncScreenNotifierProvider =
    StateNotifierProvider<SyncScreenNotifier, SyncScreenState>((Ref ref) {
      return SyncScreenNotifier(ref, null);
    });

// SelectiveSyncUseCase Provider
final Provider<SelectiveSyncUseCase> selectiveSyncUseCaseProvider =
    Provider<SelectiveSyncUseCase>((Ref ref) {
      final GetIntegrationStatusUseCase getIntegrationStatusUseCase = ref.watch(
        getIntegrationStatusUseCaseProvider,
      );
      final WorkoutSyncFacade workoutSyncFacade = ref.watch(
        workoutSyncFacadeProvider,
      );
      return SelectiveSyncUseCase(
        getIntegrationStatusUseCase,
        workoutSyncFacade,
      );
    });

// WorkoutRefreshFacade Provider
final Provider<WorkoutRefreshFacade> workoutRefreshFacadeProvider =
    Provider<WorkoutRefreshFacade>((Ref ref) {
      final SelectiveSyncUseCase selectiveSyncUseCase = ref.watch(
        selectiveSyncUseCaseProvider,
      );
      return WorkoutRefreshFacade(selectiveSyncUseCase);
    });

// WorkoutRefreshNotifier Provider
final StateNotifierProvider<WorkoutRefreshNotifier, WorkoutRefreshState>
workoutRefreshNotifierProvider =
    StateNotifierProvider<WorkoutRefreshNotifier, WorkoutRefreshState>((
      Ref ref,
    ) {
      final WorkoutRefreshFacade workoutRefreshFacade = ref.watch(
        workoutRefreshFacadeProvider,
      );
      return WorkoutRefreshNotifier(workoutRefreshFacade);
    });
