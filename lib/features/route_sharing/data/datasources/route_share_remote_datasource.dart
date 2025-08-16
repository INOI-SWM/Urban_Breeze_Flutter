import 'package:http/http.dart' as http;
import 'package:ridingmate/features/route_sharing/data/models/route_share_response_model.dart';
import 'package:ridingmate/shared/api/data/constants/api_endpoints.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

class RouteShareRemoteDataSource extends BaseRemoteDataSource {
  RouteShareRemoteDataSource({super.client});

  Future<ApiResponseModel<RouteShareResponseModel>> getShareLink(
    String routeId,
  ) async {
    final http.Response response = await get(ApiEndpoints.routeShare(routeId));
    final Map<String, dynamic> json = decodeResponse(response);
    return ApiResponseModel<RouteShareResponseModel>.fromJson(
      json,
      (Map<String, dynamic> dataJson) =>
          RouteShareResponseModel.fromJson(dataJson),
    );
  }
}
