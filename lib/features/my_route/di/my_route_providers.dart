import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/my_route/application/usecases/get_my_route_list_usecase.dart';
import 'package:ridingmate/features/my_route/data/datasources/my_route_remote_datasource.dart';
import 'package:ridingmate/features/my_route/data/repositories/my_route_repository_impl.dart';
import 'package:ridingmate/features/my_route/domain/repositories/my_route_repository.dart';

final Provider<MyRouteRemoteDataSource> myRouteRemoteDataSourceProvider =
    Provider<MyRouteRemoteDataSource>((Ref<MyRouteRemoteDataSource> ref) {
      return MyRouteRemoteDataSource();
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
