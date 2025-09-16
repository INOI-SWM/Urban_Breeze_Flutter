import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';

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

  /// Multipart/form-data 요청 (파일 업로드용)
  Future<http.StreamedResponse> postMultipart(
    String endpoint, {
    required Map<String, String> fields,
    required Map<String, http.MultipartFile> files,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final Uri uri = _buildUri(endpoint, queryParameters);
    final http.MultipartRequest request = http.MultipartRequest('POST', uri);

    // 헤더 설정 (multipart는 Content-Type을 자동으로 설정)
    request.headers.addAll(_mergeHeaders(headers));
    request.headers.remove('Content-Type'); // multipart는 자동 설정

    // 필드와 파일 추가
    request.fields.addAll(fields);
    request.files.addAll(files.values);

    return await _executeStreamedRequest(() => _client.send(request));
  }

  Map<String, dynamic> decodeResponse(http.Response response) {
    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const ParsingException('서버 응답이 유효한 JSON 형식이 아닙니다');
    }
  }

  /// HTTP 요청 실행 및 기본 예외 처리
  /// BaseDomainException을 사용하여 일관된 예외 처리 제공
  Future<http.Response> _executeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } on SocketException {
      throw const NetworkException('인터넷 연결을 확인해주세요');
    } on FormatException {
      rethrow;
    } on http.ClientException catch (e) {
      throw NetworkException('클라이언트 요청 오류: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('HTTP 요청 오류: ${e.message}');
    } catch (e) {
      throw NetworkException('네트워크 오류: ${e.toString()}');
    }
  }

  /// StreamedResponse 요청 실행 및 기본 예외 처리
  Future<http.StreamedResponse> _executeStreamedRequest(
    Future<http.StreamedResponse> Function() request,
  ) async {
    try {
      return await request();
    } on SocketException {
      throw const NetworkException('인터넷 연결을 확인해주세요');
    } on http.ClientException catch (e) {
      throw NetworkException('클라이언트 요청 오류: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException('HTTP 요청 오류: ${e.message}');
    } catch (e) {
      throw NetworkException('네트워크 오류: ${e.toString()}');
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
