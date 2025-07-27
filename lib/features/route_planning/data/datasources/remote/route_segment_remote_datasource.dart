import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/models/route_segment_api_request_model.dart';
import 'package:ridingmate/features/route_planning/data/models/route_segment_api_response_model.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';
import 'package:ridingmate/shared/domain/exceptions/base_domain_exception.dart';

class RouteSegmentRemoteDatasource extends BaseRemoteDataSource {
  RouteSegmentRemoteDatasource({super.client});

  Future<RouteApiResponseModel> fetchRoute(
    LatLng start,
    LatLng end,
    String routeMode,
  ) async {
    try {
      final RouteSegmentApiRequestModel requestBody =
          RouteSegmentApiRequestModel(start: start, end: end);

      // 추가적인 헤더
      final Map<String, String> additionalHeaders = <String, String>{
        'Accept':
            'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
      };

      final http.Response response = await post(
        '/api/routes/segment',
        body: requestBody,
        headers: additionalHeaders,
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonMap = decodeResponse(response);
      if (statusCode == 200 || statusCode == 201) {
        final ApiResponseModel<RouteApiResponseModel> apiResp =
            ApiResponseModel<RouteApiResponseModel>.fromJson(
              jsonMap,
              (Map<String, dynamic> data) =>
                  RouteApiResponseModel.fromJson(data),
            );
        return apiResp.data;
      }
      throw ServerException(
        '서버 오류 (${response.statusCode}) ${jsonMap['message']}',
      );
    } on SocketException {
      throw const NetworkException('인터넷 연결을 확인해주세요');
    } on FormatException {
      throw const ParsingException('서버 응답 데이터 형식이 잘못되었습니다');
    } on ServerException {
      rethrow;
    } on ParsingException {
      rethrow;
    } catch (e) {
      throw NetworkException('네트워크 오류: ${e.toString()}');
    }
  }
}
