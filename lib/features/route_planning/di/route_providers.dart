import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:ridingmate/features/route_planning/application/use_cases/route_planning_facade.dart';
import 'package:ridingmate/features/route_planning/data/datasources/route_remote_datasource.dart';
import 'package:ridingmate/features/route_planning/data/repositories/route_repository_impl.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';

final Provider<http.Client> httpClientProvider = Provider<http.Client>((
  Ref<http.Client> ref,
) {
  return http.Client();
});

final Provider<RouteRemoteDataSource> routeRemoteDataSourceProvider =
    Provider<RouteRemoteDataSource>((Ref<RouteRemoteDataSource> ref) {
      final http.Client client = ref.watch(httpClientProvider);
      return RouteRemoteDataSourceImpl(client: client);
    });

final Provider<RouteRepository> routeRepositoryProvider =
    Provider<RouteRepository>((Ref<RouteRepository> ref) {
      final RouteRemoteDataSource remoteDataSource = ref.watch(
        routeRemoteDataSourceProvider,
      );
      return RouteRepositoryImpl(remoteDataSource: remoteDataSource);
    });

final Provider<RoutePlanningFacade> routePlanningFacadeProvider =
    Provider<RoutePlanningFacade>((Ref<RoutePlanningFacade> ref) {
      final RouteRepository routeRepository = ref.watch(
        routeRepositoryProvider,
      );
      return RoutePlanningFacade(routeRepository: routeRepository);
    });
