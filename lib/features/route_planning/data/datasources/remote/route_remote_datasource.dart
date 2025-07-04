import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:ridingmate/features/route_planning/data/models/route_save_request_model.dart';
import 'package:ridingmate/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:ridingmate/shared/data/datasources/base_remote_datasource.dart';

class RouteRemoteDatasource extends BaseRemoteDataSource {
  RouteRemoteDatasource({super.client});

  Future<void> saveRoute(RouteSaveRequestModel request) async {
    try {
      final http.Response response = await post(
        '/api/routes',
        body: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // TODO: 저장 성공
        return;
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
