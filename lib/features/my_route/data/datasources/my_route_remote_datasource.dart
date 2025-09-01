import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/my_route/data/models/my_route_detail_model.dart';
import 'package:urban_breeze/features/my_route/data/models/my_route_filter_model.dart';
import 'package:urban_breeze/features/my_route/data/models/my_route_list_data_model.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class MyRouteRemoteDataSource extends BaseRemoteDataSource {
  MyRouteRemoteDataSource({super.client});

  Future<ApiResponseModel<MyRouteListDataModel>> getRouteList(
    MyRouteFilterModel filter,
  ) async {
    final http.Response response = await get(
      ApiEndpoints.routes,
      queryParameters: filter.toQueryParameters(),
    );

    final Map<String, dynamic> json = decodeResponse(response);

    return ApiResponseModel<MyRouteListDataModel>.fromJson(
      json,
      (Map<String, dynamic> dataJson) =>
          MyRouteListDataModel.fromJson(dataJson),
    );
  }

  Future<ApiResponseModel<MyRouteDetailModel>> getRouteDetail(
    String routeId,
  ) async {
    final http.Response response = await get('/api/routes/$routeId');
    final Map<String, dynamic> json = decodeResponse(response);

    return ApiResponseModel<MyRouteDetailModel>.fromJson(
      json,
      (Map<String, dynamic> dataJson) => MyRouteDetailModel.fromJson(dataJson),
    );
  }
}
