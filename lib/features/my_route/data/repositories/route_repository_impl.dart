import 'package:ridingmate/features/my_route/data/datasources/route_remote_datasource.dart';
import 'package:ridingmate/features/my_route/data/models/route_filter_model.dart';
import 'package:ridingmate/features/my_route/data/models/route_list_data_model.dart';
import 'package:ridingmate/features/my_route/domain/repositories/route_repository.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

class RouteRepositoryImpl implements RouteRepository {
  const RouteRepositoryImpl({required RouteRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final RouteRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResponseModel<RouteListDataModel>> getRouteList(
    RouteFilterModel filter,
  ) async {
    return await _remoteDataSource.getRouteList(filter);
  }
}
