import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ridingmate/features/route_planning/application/use_cases/create_route_use_case.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/fit_map_to_routes_use_case.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/get_current_location_use_case.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/manage_route_pins_use_case.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/route_planning_facade.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/route_stats_use_case.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/save_route_use_case.dart';
import 'package:ridingmate/features/route_planning/data/datasources/location_datasource.dart';
import 'package:ridingmate/features/route_planning/data/datasources/remote/route_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/datasources/remote/route_segment_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/repositories/location_repository_impl.dart';
import 'package:ridingmate/features/route_planning/data/repositories/route_repository_impl.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/location_repository.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';
import 'package:ridingmate/features/route_planning/domain/services/bbox_service.dart';

// Infrastructure Providers
final Provider<http.Client> httpClientProvider = Provider<http.Client>((
  Ref<http.Client> ref,
) {
  return http.Client();
});

// Domain Service Providers
final Provider<BboxService> bboxServiceProvider = Provider<BboxService>((
  Ref<BboxService> ref,
) {
  return const BboxService();
});

// Data Source Providers
final Provider<GeolocatorLocationDataSource> locationDataSourceProvider =
    Provider<GeolocatorLocationDataSource>((
      Ref<GeolocatorLocationDataSource> ref,
    ) {
      return GeolocatorLocationDataSource();
    });

final Provider<RouteSegmentRemoteDatasource> routeRemoteDataSourceProvider =
    Provider<RouteSegmentRemoteDatasource>((
      Ref<RouteSegmentRemoteDatasource> ref,
    ) {
      final http.Client client = ref.watch(httpClientProvider);
      return RouteSegmentRemoteDatasource(client: client);
    });

final Provider<RouteRemoteDatasource> routeSaveRemoteDataSourceProvider =
    Provider<RouteRemoteDatasource>((Ref<RouteRemoteDatasource> ref) {
      final http.Client client = ref.watch(httpClientProvider);
      return RouteRemoteDatasource(client: client);
    });

// Repository Providers
final Provider<LocationRepository> locationRepositoryProvider =
    Provider<LocationRepository>((Ref<LocationRepository> ref) {
      final GeolocatorLocationDataSource dataSource = ref.watch(
        locationDataSourceProvider,
      );
      return LocationRepositoryImpl(dataSource: dataSource);
    });

final Provider<RouteRepository> routeRepositoryProvider =
    Provider<RouteRepository>((Ref<RouteRepository> ref) {
      final RouteSegmentRemoteDatasource remoteDataSource = ref.watch(
        routeRemoteDataSourceProvider,
      );
      final RouteRemoteDatasource saveRemoteDataSource = ref.watch(
        routeSaveRemoteDataSourceProvider,
      );
      return RouteRepositoryImpl(
        routeRemoteDataSource: remoteDataSource,
        routeSaveRemoteDataSource: saveRemoteDataSource,
      );
    });

// Use Case Providers
final Provider<CreateRouteUseCase> createRouteUseCaseProvider =
    Provider<CreateRouteUseCase>((Ref<CreateRouteUseCase> ref) {
      final RouteRepository routeRepository = ref.watch(
        routeRepositoryProvider,
      );
      return CreateRouteUseCase(routeRepository: routeRepository);
    });

final Provider<SaveRouteUseCase> saveRouteUseCaseProvider =
    Provider<SaveRouteUseCase>((Ref<SaveRouteUseCase> ref) {
      final BboxService bboxService = ref.watch(bboxServiceProvider);
      final RouteRepository routeRepository = ref.watch(
        routeRepositoryProvider,
      );
      final RouteStatsUseCase routeStatsUseCase = ref.watch(
        routeStatsUseCaseProvider,
      );
      return SaveRouteUseCase(
        bboxService: bboxService,
        routeRepository: routeRepository,
        routeStatsUseCase: routeStatsUseCase,
      );
    });

final Provider<GetCurrentLocationUseCase> getCurrentLocationUseCaseProvider =
    Provider<GetCurrentLocationUseCase>((Ref<GetCurrentLocationUseCase> ref) {
      final LocationRepository locationRepository = ref.watch(
        locationRepositoryProvider,
      );
      return GetCurrentLocationUseCase(locationRepository: locationRepository);
    });

final Provider<ManageRoutePinsUseCase> manageRoutePinsUseCaseProvider =
    Provider<ManageRoutePinsUseCase>((Ref<ManageRoutePinsUseCase> ref) {
      return const ManageRoutePinsUseCase();
    });

final Provider<RouteStatsUseCase> routeStatsUseCaseProvider =
    Provider<RouteStatsUseCase>((Ref<RouteStatsUseCase> ref) {
      return const RouteStatsUseCase();
    });

final Provider<FitMapToRoutesUseCase> fitMapToRoutesUseCaseProvider =
    Provider<FitMapToRoutesUseCase>((Ref<FitMapToRoutesUseCase> ref) {
      final BboxService bboxService = ref.watch(bboxServiceProvider);
      return FitMapToRoutesUseCase(bboxService: bboxService);
    });

// Facade Provider
final Provider<RoutePlanningFacade> routePlanningFacadeProvider =
    Provider<RoutePlanningFacade>((Ref<RoutePlanningFacade> ref) {
      final CreateRouteUseCase createRouteUseCase = ref.watch(
        createRouteUseCaseProvider,
      );
      final SaveRouteUseCase saveRouteUseCase = ref.watch(
        saveRouteUseCaseProvider,
      );
      final GetCurrentLocationUseCase getCurrentLocationUseCase = ref.watch(
        getCurrentLocationUseCaseProvider,
      );
      final ManageRoutePinsUseCase manageRoutePinsUseCase = ref.watch(
        manageRoutePinsUseCaseProvider,
      );
      final RouteStatsUseCase routeStatsUseCase = ref.watch(
        routeStatsUseCaseProvider,
      );
      final FitMapToRoutesUseCase fitMapToRoutesUseCase = ref.watch(
        fitMapToRoutesUseCaseProvider,
      );

      return RoutePlanningFacade(
        createRouteUseCase: createRouteUseCase,
        saveRouteUseCase: saveRouteUseCase,
        getCurrentLocationUseCase: getCurrentLocationUseCase,
        manageRoutePinsUseCase: manageRoutePinsUseCase,
        routeStatsUseCase: routeStatsUseCase,
        fitMapToRoutesUseCase: fitMapToRoutesUseCase,
      );
    });
