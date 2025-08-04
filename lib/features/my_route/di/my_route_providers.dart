import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/my_route/application/usecases/get_route_list_usecase.dart';
import 'package:ridingmate/features/my_route/data/datasources/route_remote_datasource.dart';
import 'package:ridingmate/features/my_route/data/repositories/route_repository_impl.dart';
import 'package:ridingmate/features/my_route/domain/repositories/route_repository.dart';

final Provider<RouteRemoteDataSource> routeRemoteDataSourceProvider =
    Provider<RouteRemoteDataSource>((Ref<RouteRemoteDataSource> ref) {
      return RouteRemoteDataSource();
    });

final Provider<RouteRepository> routeRepositoryProvider =
    Provider<RouteRepository>((Ref<RouteRepository> ref) {
      final RouteRemoteDataSource remoteDataSource = ref.watch(
        routeRemoteDataSourceProvider,
      );
      return RouteRepositoryImpl(remoteDataSource: remoteDataSource);
    });

final Provider<GetRouteListUseCase> getRouteListUseCaseProvider =
    Provider<GetRouteListUseCase>((Ref<GetRouteListUseCase> ref) {
      final RouteRepository repository = ref.watch(routeRepositoryProvider);
      return GetRouteListUseCase(repository: repository);
    });
