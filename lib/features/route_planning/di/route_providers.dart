import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/create_route_use_case.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/fit_map_to_routes_use_case.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/get_current_location_use_case.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/manage_route_pins_use_case.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/route_planning_facade.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/route_stats_use_case.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/save_route_use_case.dart';
import 'package:urban_breeze/features/route_planning/data/datasources/location_datasource.dart';
import 'package:urban_breeze/features/route_planning/data/datasources/remote/route_remote_datasource.dart';
import 'package:urban_breeze/features/route_planning/data/datasources/remote/route_segment_remote_datasource.dart';
import 'package:urban_breeze/features/route_planning/data/repositories/location_repository_impl.dart';
import 'package:urban_breeze/features/route_planning/data/repositories/route_repository_impl.dart';
import 'package:urban_breeze/features/route_planning/data/repositories/route_segment_repository_impl.dart';
import 'package:urban_breeze/features/route_planning/domain/repositories/location_repository.dart';
import 'package:urban_breeze/features/route_planning/domain/repositories/route_repository.dart';
import 'package:urban_breeze/features/route_planning/domain/repositories/route_segment_repository.dart';
import 'package:urban_breeze/features/route_planning/domain/services/bbox_service.dart';

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

final Provider<RouteSegmentRemoteDataSource>
routeSegmentRemoteDataSourceProvider = Provider<RouteSegmentRemoteDataSource>((
  Ref<RouteSegmentRemoteDataSource> ref,
) {
  final http.Client client = ref.watch(authorizedHttpClientProvider);
  return RouteSegmentRemoteDataSource(client: client);
});

final Provider<RouteRemoteDataSource> routeRemoteDataSourceProvider =
    Provider<RouteRemoteDataSource>((Ref<RouteRemoteDataSource> ref) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return RouteRemoteDataSource(client: client);
    });

// Repository Providers
final Provider<LocationRepository> locationRepositoryProvider =
    Provider<LocationRepository>((Ref<LocationRepository> ref) {
      final GeolocatorLocationDataSource dataSource = ref.watch(
        locationDataSourceProvider,
      );
      return LocationRepositoryImpl(dataSource: dataSource);
    });

final Provider<RouteSegmentRepository> routeSegmentRepositoryProvider =
    Provider<RouteSegmentRepository>((Ref<RouteSegmentRepository> ref) {
      final RouteSegmentRemoteDataSource routeSegmentRemoteDataSource = ref
          .watch(routeSegmentRemoteDataSourceProvider);

      return RouteSegmentRepositoryImpl(
        routeSegmentRemoteDataSource: routeSegmentRemoteDataSource,
      );
    });

final Provider<RouteRepository> routeRepositoryProvider =
    Provider<RouteRepository>((Ref<RouteRepository> ref) {
      final RouteRemoteDataSource routeRemoteDataSource = ref.watch(
        routeRemoteDataSourceProvider,
      );
      return RouteRepositoryImpl(routeRemoteDataSource: routeRemoteDataSource);
    });

// Use Case Providers
final Provider<CreateRouteUseCase> createRouteUseCaseProvider =
    Provider<CreateRouteUseCase>((Ref<CreateRouteUseCase> ref) {
      final RouteSegmentRepository routeRepository = ref.watch(
        routeSegmentRepositoryProvider,
      );
      return CreateRouteUseCase(routeRepository: routeRepository);
    });

final Provider<SaveRouteUseCase> saveRouteUseCaseProvider =
    Provider<SaveRouteUseCase>((Ref<SaveRouteUseCase> ref) {
      final BboxService bboxService = ref.watch(bboxServiceProvider);
      final RouteRepository routeRepository = ref.watch(
        routeRepositoryProvider,
      );
      return SaveRouteUseCase(
        bboxService: bboxService,
        routeRepository: routeRepository,
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
