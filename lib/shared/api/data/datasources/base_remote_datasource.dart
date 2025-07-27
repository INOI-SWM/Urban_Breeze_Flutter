import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

abstract class BaseRemoteDataSource {
  BaseRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  Map<String, String> get defaultHeaders => <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=utf-8',
  };

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final Uri uri = _buildUri(endpoint, queryParameters);

    return await _executeRequest(
      () => _client.get(uri, headers: _mergeHeaders(headers)),
    );
  }

  Future<http.Response> post(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final Uri uri = _buildUri(endpoint, queryParameters);
    final String? encodedBody = body != null ? json.encode(body) : null;

    return await _executeRequest(
      () =>
          _client.post(uri, headers: _mergeHeaders(headers), body: encodedBody),
    );
  }

  Future<http.Response> put(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final Uri uri = _buildUri(endpoint, queryParameters);
    final String? encodedBody = body != null ? json.encode(body) : null;

    return await _executeRequest(
      () =>
          _client.put(uri, headers: _mergeHeaders(headers), body: encodedBody),
    );
  }

  Future<http.Response> patch(
    String endpoint, {
    Object? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final Uri uri = _buildUri(endpoint, queryParameters);
    final String? encodedBody = body != null ? json.encode(body) : null;

    return await _executeRequest(
      () => _client.patch(
        uri,
        headers: _mergeHeaders(headers),
        body: encodedBody,
      ),
    );
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final Uri uri = _buildUri(endpoint, queryParameters);

    return await _executeRequest(
      () => _client.delete(uri, headers: _mergeHeaders(headers)),
    );
  }

  Map<String, dynamic> decodeResponse(http.Response response) {
    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const FormatException('서버 응답이 유효한 JSON 형식이 아닙니다');
    }
  }

  /// HTTP 요청 실행 및 기본 예외 처리
  /// 각 Feature별 구체적인 예외는 상속받은 클래스에서 처리
  Future<http.Response> _executeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } on SocketException {
      throw const SocketException('인터넷 연결을 확인해주세요');
    } on FormatException {
      rethrow;
    } catch (e) {
      throw Exception('네트워크 오류: ${e.toString()}');
    }
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParameters) {
    final String url = '$baseUrl$endpoint';
    return queryParameters != null
        ? Uri.parse(url).replace(queryParameters: queryParameters)
        : Uri.parse(url);
  }

  Map<String, String> _mergeHeaders(Map<String, String>? additionalHeaders) {
    final Map<String, String> headers = Map<String, String>.from(
      defaultHeaders,
    );
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  void dispose() {
    _client.close();
  }
}
