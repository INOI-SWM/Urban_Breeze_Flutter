import 'package:http/http.dart' as http;
import 'package:ridingmate/features/my_route/data/models/my_route_filter_model.dart';
import 'package:ridingmate/features/my_route/data/models/my_route_list_data_model.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

class MyRouteRemoteDataSource extends BaseRemoteDataSource {
  MyRouteRemoteDataSource({super.client});

  Future<ApiResponseModel<MyRouteListDataModel>> getRouteList(
    MyRouteFilterModel filter,
  ) async {
    final http.Response response = await get(
      '/api/routes',
      queryParameters: filter.toQueryParameters(),
    );

    final Map<String, dynamic> json = decodeResponse(response);

    return ApiResponseModel<MyRouteListDataModel>.fromJson(
      json,
      (Map<String, dynamic> dataJson) =>
          MyRouteListDataModel.fromJson(dataJson),
    );
  }
}
