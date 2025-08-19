import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';
import 'package:urban_breeze/features/route_sharing/application/facades/route_sharing_facade.dart';
import 'package:urban_breeze/features/route_sharing/application/use_cases/get_route_share_link_use_case.dart';
import 'package:urban_breeze/features/route_sharing/data/datasources/route_share_remote_datasource.dart';
import 'package:urban_breeze/features/route_sharing/data/repositories/route_share_repository_impl.dart';
import 'package:urban_breeze/features/route_sharing/domain/repositories/route_share_repository.dart';

final Provider<RouteShareRemoteDataSource> routeShareRemoteDataSourceProvider =
    Provider<RouteShareRemoteDataSource>((Ref<RouteShareRemoteDataSource> ref) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return RouteShareRemoteDataSource(client: client);
    });

final Provider<RouteShareRepository> routeShareRepositoryProvider =
    Provider<RouteShareRepository>((Ref<RouteShareRepository> ref) {
      final RouteShareRemoteDataSource remote = ref.watch(
        routeShareRemoteDataSourceProvider,
      );
      return RouteShareRepositoryImpl(remote: remote);
    });

final Provider<GetRouteShareLinkUseCase> getRouteShareLinkUseCaseProvider =
    Provider<GetRouteShareLinkUseCase>((Ref<GetRouteShareLinkUseCase> ref) {
      final RouteShareRepository repo = ref.watch(routeShareRepositoryProvider);
      return GetRouteShareLinkUseCase(repository: repo);
    });

final Provider<RouteSharingFacade> routeSharingFacadeProvider =
    Provider<RouteSharingFacade>((Ref<RouteSharingFacade> ref) {
      final GetRouteShareLinkUseCase useCase = ref.watch(
        getRouteShareLinkUseCaseProvider,
      );
      return RouteSharingFacade(getRouteShareLinkUseCase: useCase);
    });
