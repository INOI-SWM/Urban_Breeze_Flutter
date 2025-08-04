import 'package:ridingmate/features/my_route/data/datasources/my_route_remote_datasource.dart';
import 'package:ridingmate/features/my_route/data/mappers/my_route_mapper.dart';
import 'package:ridingmate/features/my_route/data/models/my_route_filter_model.dart';
import 'package:ridingmate/features/my_route/data/models/my_route_list_data_model.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route_filter.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route_list.dart';
import 'package:ridingmate/features/my_route/domain/repositories/my_route_repository.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

class MyRouteRepositoryImpl implements MyRouteRepository {
  const MyRouteRepositoryImpl({
    required MyRouteRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final MyRouteRemoteDataSource _remoteDataSource;

  @override
  Future<MyRouteList> getMyRouteList(MyRouteFilter filter) async {
    // 도메인 엔티티를 data 모델로 변환
    final MyRouteFilterModel filterModel = MyRouteMapper.toFilterModel(filter);

    // API 호출
    final ApiResponseModel<MyRouteListDataModel> response =
        await _remoteDataSource.getRouteList(filterModel);

    // API 응답을 도메인 엔티티로 변환
    return MyRouteMapper.fromApiResponse(response);
  }
}
