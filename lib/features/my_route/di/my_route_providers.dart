import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';
import 'package:urban_breeze/features/my_route/application/usecases/get_my_route_detail_usecase.dart';
import 'package:urban_breeze/features/my_route/application/usecases/get_my_route_list_usecase.dart';
import 'package:urban_breeze/features/my_route/application/usecases/get_route_gpx_usecase.dart';
import 'package:urban_breeze/features/my_route/data/datasources/my_route_remote_datasource.dart';
import 'package:urban_breeze/features/my_route/data/repositories/my_route_repository_impl.dart';
import 'package:urban_breeze/features/my_route/domain/repositories/my_route_repository.dart';

final Provider<MyRouteRemoteDataSource> myRouteRemoteDataSourceProvider =
    Provider<MyRouteRemoteDataSource>((Ref<MyRouteRemoteDataSource> ref) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return MyRouteRemoteDataSource(client: client);
    });

final Provider<MyRouteRepository> myRouteRepositoryProvider =
    Provider<MyRouteRepository>((Ref<MyRouteRepository> ref) {
      final MyRouteRemoteDataSource remoteDataSource = ref.watch(
        myRouteRemoteDataSourceProvider,
      );
      return MyRouteRepositoryImpl(remoteDataSource: remoteDataSource);
    });

final Provider<GetMyRouteListUseCase> getMyRouteListUseCaseProvider =
    Provider<GetMyRouteListUseCase>((Ref<GetMyRouteListUseCase> ref) {
      final MyRouteRepository repository = ref.watch(myRouteRepositoryProvider);
      return GetMyRouteListUseCase(repository: repository);
    });

final Provider<GetMyRouteDetailUseCase> getMyRouteDetailUseCaseProvider =
    Provider<GetMyRouteDetailUseCase>((Ref<GetMyRouteDetailUseCase> ref) {
      final MyRouteRepository repository = ref.watch(myRouteRepositoryProvider);
      return GetMyRouteDetailUseCase(repository: repository);
    });

final Provider<GetRouteGpxUseCase> getRouteGpxUseCaseProvider =
    Provider<GetRouteGpxUseCase>((Ref<GetRouteGpxUseCase> ref) {
      final MyRouteRepository repository = ref.watch(myRouteRepositoryProvider);
      return GetRouteGpxUseCase(repository: repository);
    });
