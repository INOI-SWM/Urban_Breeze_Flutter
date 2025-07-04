import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:ridingmate/features/route_planning/data/models/route_save_request_model.dart';
import 'package:ridingmate/features/route_planning/data/models/route_save_response_model.dart';
import 'package:ridingmate/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:ridingmate/shared/api/data/models/api_response.dart';

class RouteRemoteDatasource extends BaseRemoteDataSource {
  RouteRemoteDatasource({super.client});

  Future<RouteSaveResponseModel> saveRoute(
    RouteSaveRequestModel request,
  ) async {
    try {
      final http.Response response = await post(
        '/api/routes',
        body: request.toJson(),
      );

      final int statusCode = response.statusCode;
      final Map<String, dynamic> jsonMap = decodeResponse(response);

      if (statusCode == 200 || statusCode == 201) {
        final ApiResponse<RouteSaveResponseModel> apiResp =
            ApiResponse<RouteSaveResponseModel>.fromJson(
              jsonMap,
              (Map<String, dynamic> data) =>
                  RouteSaveResponseModel.fromJson(data),
            );

        return apiResp.data; // for save maybe void no return, we ignore data
      }

      throw RouteSaveException('서버 오류 (${response.statusCode})');
    } on SocketException {
      throw const RouteSaveException('인터넷 연결을 확인해주세요');
    } on FormatException {
      throw const RouteSaveException('서버 응답 데이터 형식이 잘못되었습니다');
    } on RouteSaveException {
      rethrow;
    } catch (e) {
      throw RouteSaveException('네트워크 오류: ${e.toString()}');
    }
  }
}
