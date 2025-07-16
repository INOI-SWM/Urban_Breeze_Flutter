import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/exceptions/place_search_domain_exceptions.dart';
import '../models/kakao_search_response_model.dart';

class KakaoSearchDataSource {
  KakaoSearchDataSource({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _baseUrl =
      'https://dapi.kakao.com/v2/local/search/keyword.json';

  String get _restApiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';

  Future<KakaoSearchResponseModel> searchPlaces({required String query}) async {
    if (_restApiKey.isEmpty) {
      throw const PlaceSearchServerException('카카오 REST API 키가 설정되지 않았습니다');
    }

    try {
      final Uri uri = Uri.parse(
        _baseUrl,
      ).replace(queryParameters: <String, dynamic>{'query': query});

      final Map<String, String> headers = <String, String>{
        'Authorization': 'KakaoAK $_restApiKey',
        'Content-Type': 'application/json',
      };

      final http.Response response = await _httpClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;
        return KakaoSearchResponseModel.fromJson(jsonData);
      } else {
        String errorMessage = 'API 요청 실패';

        try {
          final Map<String, dynamic> errorData =
              json.decode(response.body) as Map<String, dynamic>;
          errorMessage =
              errorData['errorMessage'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {}

        throw PlaceSearchServerException(
          'API 요청 실패 (${response.statusCode}): $errorMessage',
        );
      }
    } on SocketException {
      throw const PlaceSearchNetworkException('인터넷 연결을 확인해주세요');
    } on HttpException catch (e) {
      throw PlaceSearchNetworkException('HTTP 요청 오류: ${e.message}');
    } on http.ClientException catch (e) {
      throw PlaceSearchNetworkException('클라이언트 요청 오류: ${e.message}');
    } on FormatException {
      throw const PlaceSearchParsingException('응답 데이터 형식이 올바르지 않습니다');
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
