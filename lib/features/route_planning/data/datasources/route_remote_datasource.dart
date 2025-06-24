import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/data/exceptions/route_exceptions.dart';
import 'package:ridingmate/features/route_planning/data/models/route_api_response_model.dart';

abstract class RouteRemoteDataSource {
  Future<RouteApiResponseModel> fetchRoute(
    LatLng start,
    LatLng end,
    String routeMode,
  );
}

class RouteRemoteDataSourceImpl implements RouteRemoteDataSource {
  RouteRemoteDataSourceImpl({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  static final String _apiKey = dotenv.env['OPENROUTE_API_KEY'] ?? '';
  static final String _baseUrl = dotenv.env['ORS_BASE_URL'] ?? '';

  @override
  Future<RouteApiResponseModel> fetchRoute(
    LatLng start,
    LatLng end,
    String routeMode,
  ) async {
    try {
      final http.Response response = await _makeRouteRequest(
        start,
        end,
        routeMode,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body) as Map<String, dynamic>;
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

  Future<http.Response> _makeRouteRequest(
    LatLng start,
    LatLng end,
    String routeMode,
  ) {
    final String url = '$_baseUrl$routeMode/geojson';
    final Map<String, Object> body = <String, Object>{
      'coordinates': <List<double>>[
        <double>[start.longitude, start.latitude],
        <double>[end.longitude, end.latitude],
      ],
      'elevation': true,
    };

    return _client.post(
      Uri.parse(url),
      headers: <String, String>{
        'Accept':
            'application/json, application/geo+json, application/gpx+xml, img/png; charset=utf-8',
        'Authorization': _apiKey.isNotEmpty ? _apiKey : '',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: json.encode(body),
    );
  }

  void dispose() {
    _client.close();
  }
}
