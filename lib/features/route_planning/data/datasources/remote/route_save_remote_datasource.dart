import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ridingmate/features/route_planning/data/models/route_save_request_model.dart';
import 'package:ridingmate/features/route_planning/domain/exceptions/route_domain_exceptions.dart';

abstract class RouteSaveRemoteDataSource {
  Future<void> saveRoute(RouteSaveRequestModel request);
}

class RouteSaveRemoteDataSourceImpl implements RouteSaveRemoteDataSource {
  RouteSaveRemoteDataSourceImpl({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  // 환경변수에서 API 정보 가져오기
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  @override
  Future<void> saveRoute(RouteSaveRequestModel request) async {
    try {
      debugPrint('request: ${request.toJson()}');
      final http.Response response = await _makeRouteRequest(request);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 저장 성공
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

  Future<http.Response> _makeRouteRequest(RouteSaveRequestModel request) {
    final String url = '$_baseUrl/routes';

    return _client.post(
      Uri.parse(url),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: json.encode(request.toJson()),
    );
  }

  void dispose() {
    _client.close();
  }
}
