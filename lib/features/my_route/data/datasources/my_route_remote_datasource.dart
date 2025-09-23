import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
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
    final http.Response response = await get(ApiEndpoints.routeDetail(routeId));
    final Map<String, dynamic> json = decodeResponse(response);
    return ApiResponseModel<MyRouteDetailModel>.fromJson(
      json,
      (Map<String, dynamic> dataJson) => MyRouteDetailModel.fromJson(dataJson),
    );
  }

  Future<ApiResponseModel<String>> getRouteGPX(String routeId) async {
    final http.Response response = await get(
      ApiEndpoints.routeGPXDownload(routeId),
    );

    // HTTP 상태 코드 확인
    if (response.statusCode != 200) {
      throw NetworkException('GPX 다운로드 실패: HTTP ${response.statusCode}');
    }

    // 서버에서 body에 GPX 데이터를 직접 string으로 보내므로 JSON parsing 없이 처리
    final String gpxData = response.body;

    if (gpxData.isEmpty) {
      throw const NetworkException('GPX 데이터가 비어있습니다');
    }

    // GPX 형식 기본 검증
    if (!gpxData.contains('<?xml') || !gpxData.contains('<gpx')) {
      throw const NetworkException('유효하지 않은 GPX 형식입니다');
    }

    // ApiResponseModel로 감싸서 반환 (다른 API와 일관성 유지)
    return ApiResponseModel<String>(
      code: '200',
      message: 'success',
      data: gpxData,
    );
  }
}
