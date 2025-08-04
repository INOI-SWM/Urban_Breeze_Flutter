import 'package:ridingmate/features/my_route/data/datasources/route_remote_datasource.dart';
import 'package:ridingmate/features/my_route/data/mappers/route_mapper.dart';
import 'package:ridingmate/features/my_route/data/models/route_filter_model.dart';
import 'package:ridingmate/features/my_route/data/models/route_list_data_model.dart';
import 'package:ridingmate/features/my_route/domain/entities/route_filter.dart';
import 'package:ridingmate/features/my_route/domain/entities/route_list.dart';
import 'package:ridingmate/features/my_route/domain/repositories/route_repository.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

class RouteRepositoryImpl implements RouteRepository {
  const RouteRepositoryImpl({required RouteRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final RouteRemoteDataSource _remoteDataSource;

  @override
  Future<RouteList> getRouteList(RouteFilter filter) async {
    // 도메인 엔티티를 data 모델로 변환
    final RouteFilterModel filterModel = RouteMapper.toFilterModel(filter);

    // API 호출
    final ApiResponseModel<RouteListDataModel> response =
        await _remoteDataSource.getRouteList(filterModel);

    // API 응답을 도메인 엔티티로 변환
    return RouteMapper.fromApiResponse(response);
  }
}
