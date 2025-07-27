import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ridingmate/core/exceptions/base_domain_exception.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

import '../models/place_search_response_model.dart';

class RemotePlaceSearchDataSource {
  RemotePlaceSearchDataSource({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  Future<PlaceSearchResponseModel> searchPlaces({
    required String query,
    required double longitude,
    required double latitude,
  }) async {
    try {
      final Uri uri = Uri.parse('$_baseUrl/api/routes/search').replace(
        queryParameters: <String, dynamic>{
          'query': query,
          'lon': longitude.toString(),
          'lat': latitude.toString(),
        },
      );

      final Map<String, String> headers = <String, String>{
        'Content-Type': 'application/json',
      };

      final http.Response response = await _httpClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
            json.decode(response.body) as Map<String, dynamic>;

        final ApiResponseModel<PlaceSearchData> apiResponse =
            ApiResponseModel<PlaceSearchData>.fromJson(
              jsonData,
              (Map<String, dynamic> data) => PlaceSearchData.fromJson(data),
            );

        return apiResponse;
      } else {
        String errorMessage = 'API 요청 실패';

        try {
          final Map<String, dynamic> errorData =
              json.decode(response.body) as Map<String, dynamic>;
          errorMessage =
              errorData['errorMessage'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {}

        throw ServerException(
          'API 요청 실패 (${response.statusCode}): $errorMessage',
        );
      }
    } on ServerException {
      rethrow;
    } on BaseDomainException {
      rethrow; // 이미 우리가 정의한 예외라면 그대로 전달
    } catch (e) {
      throw ParsingException('알 수 없는 오류가 발생했습니다: ${e.toString()}');
    }
    // BaseRemoteDataSource에서 NetworkException, basic ParsingException 처리
  }

  void dispose() {
    _httpClient.close();
  }
}
