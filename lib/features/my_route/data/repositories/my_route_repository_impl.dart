import 'package:urban_breeze/features/my_route/data/datasources/my_route_remote_datasource.dart';
import 'package:urban_breeze/features/my_route/data/mappers/my_route_mapper.dart';
import 'package:urban_breeze/features/my_route/data/models/my_route_detail_model.dart';
import 'package:urban_breeze/features/my_route/data/models/my_route_filter_model.dart';
import 'package:urban_breeze/features/my_route/data/models/my_route_list_data_model.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_detail.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_filter.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_list.dart';
import 'package:urban_breeze/features/my_route/domain/repositories/my_route_repository.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class MyRouteRepositoryImpl implements MyRouteRepository {
  const MyRouteRepositoryImpl({
    required MyRouteRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final MyRouteRemoteDataSource _remoteDataSource;

  @override
  Future<MyRouteList> getMyRouteList(MyRouteFilter filter) async {
    final MyRouteFilterModel filterModel = MyRouteMapper.toFilterModel(filter);

    final ApiResponseModel<MyRouteListDataModel> response =
        await _remoteDataSource.getRouteList(filterModel);

    return MyRouteMapper.fromApiResponse(response);
  }

  @override
  Future<MyRouteDetail> getRouteDetail(String routeId) async {
    final ApiResponseModel<MyRouteDetailModel> response =
        await _remoteDataSource.getRouteDetail(routeId);

    return MyRouteMapper.fromDetailApiResponse(response);
  }

  @override
  Future<String> getRouteGPX(String routeId) async {
    final ApiResponseModel<String> response = await _remoteDataSource
        .getRouteGPX(routeId);

    return response.data;
  }

  @override
  Future<void> deleteRoute(String routeId) async {
    await _remoteDataSource.deleteRoute(routeId);
  }

  @override
  Future<void> saveSharedRoute(String routeId) async {
    await _remoteDataSource.saveSharedRoute(routeId);
  }
}
