import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/exceptions/place_search_domain_exceptions.dart';
import '../models/naver_search_response_model.dart';

class NaverSearchDataSource {
  NaverSearchDataSource({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _baseUrl =
      'https://openapi.naver.com/v1/search/local.json';

  String get _clientId => dotenv.env['NAVER_CLIENT_ID'] ?? '';
  String get _clientSecret => dotenv.env['NAVER_CLIENT_SECRET'] ?? '';

  Future<NaverSearchResponse> searchPlaces({
    required String query,
    int display = 5,
  }) async {
    if (_clientId.isEmpty || _clientSecret.isEmpty) {
      throw const PlaceSearchServerException('네이버 API 키가 설정되지 않았습니다');
    }

    try {
      final Uri uri = Uri.parse(_baseUrl).replace(
        queryParameters: <String, dynamic>{
          'query': query,
          'display': display.toString(),
          'start': '1', // 기본값
          'sort': 'random', // 정확도순 내림차순 정렬
        },
      );

      final Map<String, String> headers = <String, String>{
        'X-Naver-Client-Id': _clientId,
        'X-Naver-Client-Secret': _clientSecret,
        'Content-Type': 'application/json',
      };

      final http.Response response = await _httpClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;
        return NaverSearchResponse.fromJson(jsonData);
      } else {
        String errorMessage = 'API 요청 실패';

        try {
          final Map<String, dynamic> errorData =
              json.decode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['errorMessage'] ?? errorMessage;
        } catch (_) {}

        throw PlaceSearchServerException(
          'API 요청 실패 (${response.statusCode}): $errorMessage',
        );
      }
    } on SocketException {
      throw const PlaceSearchNetworkException('인터넷 연결을 확인해주세요');
    } on FormatException {
      throw const PlaceSearchParsingException('응답 데이터 형식이 올바르지 않습니다');
    } on http.ClientException {
      throw const PlaceSearchNetworkException('네트워크 요청 중 오류가 발생했습니다');
    } catch (e) {
      // 예상하지 못한 에러
      if (e is PlaceSearchDomainException) {
        rethrow; // 이미 우리가 정의한 예외라면 그대로 전달
      }
      throw PlaceSearchParsingException('알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
