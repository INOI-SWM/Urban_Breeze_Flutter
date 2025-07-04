import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/models/route_api_response_model.dart';
import 'package:ridingmate/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:ridingmate/shared/data/datasources/base_remote_datasource.dart';

class RouteSegmentRemoteDatasource extends BaseRemoteDataSource {
  RouteSegmentRemoteDatasource({super.client});

  Future<RouteApiResponseModel> fetchRoute(
    LatLng start,
    LatLng end,
    String routeMode,
  ) async {
    try {
      final Map<String, Object> requestBody = <String, Object>{
        'coordinates': <List<double>>[
          <double>[start.longitude, start.latitude],
          <double>[end.longitude, end.latitude],
        ],
        'elevation': true,
      };

      final Map<String, String> additionalHeaders = <String, String>{
        'Accept':
            'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
      };

      final http.Response response = await post(
        '/api/routes/segment',
        body: requestBody,
        headers: additionalHeaders,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = decodeResponse(response);
        return RouteApiResponseModel.fromJson(data);
      }

      throw RouteServerException('서버 오류 (${response.statusCode})');
    } on SocketException {
      throw const RouteNetworkException('인터넷 연결을 확인해주세요');
    } on FormatException {
      throw const RouteParsingException('서버 응답 데이터 형식이 잘못되었습니다');
    } on RouteServerException {
      rethrow;
    } on RouteParsingException {
      rethrow;
    } catch (e) {
      throw RouteNetworkException('네트워크 오류: ${e.toString()}');
    }
  }
}
