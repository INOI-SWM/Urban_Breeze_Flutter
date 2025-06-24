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
import 'package:ridingmate/features/route_planning/data/datasources/route_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/repositories/location_repository_impl.dart';
import 'package:ridingmate/features/route_planning/data/repositories/route_repository_impl.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';
import 'package:ridingmate/features/route_planning/domain/services/location_service.dart';

// Infrastructure Providers
final Provider<http.Client> httpClientProvider = Provider<http.Client>((
  Ref<http.Client> ref,
) {
  return http.Client();
});

// Data Source Providers
final Provider<GeolocatorLocationDataSource> locationDataSourceProvider =
    Provider<GeolocatorLocationDataSource>((
      Ref<GeolocatorLocationDataSource> ref,
    ) {
      return GeolocatorLocationDataSource();
    });

final Provider<RouteRemoteDataSource> routeRemoteDataSourceProvider =
    Provider<RouteRemoteDataSource>((Ref<RouteRemoteDataSource> ref) {
      final http.Client client = ref.watch(httpClientProvider);
      return RouteRemoteDataSourceImpl(client: client);
    });

// Repository Providers
final Provider<LocationService> locationServiceProvider =
    Provider<LocationService>((Ref<LocationService> ref) {
      final GeolocatorLocationDataSource dataSource = ref.watch(
        locationDataSourceProvider,
      );
      return LocationRepositoryImpl(dataSource: dataSource);
    });

final Provider<RouteRepository> routeRepositoryProvider =
    Provider<RouteRepository>((Ref<RouteRepository> ref) {
      final RouteRemoteDataSource remoteDataSource = ref.watch(
        routeRemoteDataSourceProvider,
      );
      return RouteRepositoryImpl(remoteDataSource: remoteDataSource);
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
      return const SaveRouteUseCase();
    });

final Provider<GetCurrentLocationUseCase> getCurrentLocationUseCaseProvider =
    Provider<GetCurrentLocationUseCase>((Ref<GetCurrentLocationUseCase> ref) {
      final LocationService locationService = ref.watch(
        locationServiceProvider,
      );
      return GetCurrentLocationUseCase(locationService: locationService);
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
      return const FitMapToRoutesUseCase();
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
