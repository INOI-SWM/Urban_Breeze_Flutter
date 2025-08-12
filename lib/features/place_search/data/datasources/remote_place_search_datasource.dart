import 'package:http/http.dart' as http;
import 'package:ridingmate/core/exceptions/base_domain_exception.dart';
import 'package:ridingmate/shared/api/data/constants/api_endpoints.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

import '../models/place_search_response_model.dart';

class RemotePlaceSearchDataSource extends BaseRemoteDataSource {
  RemotePlaceSearchDataSource({super.client});

  Future<PlaceSearchResponseModel> searchPlaces({
    required String query,
    required double longitude,
    required double latitude,
  }) async {
    try {
      final Map<String, String> queryParameters = <String, String>{
        'query': query,
        'lon': longitude.toString(),
        'lat': latitude.toString(),
      };

      final http.Response response = await get(
        ApiEndpoints.routesSearch,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = decodeResponse(response);

        final ApiResponseModel<PlaceSearchData> apiResponse =
            ApiResponseModel<PlaceSearchData>.fromJson(
              jsonData,
              (Map<String, dynamic> data) => PlaceSearchData.fromJson(data),
            );

        return apiResponse;
      } else {
        final Map<String, dynamic> jsonData = decodeResponse(response);
        final String errorMessage =
            jsonData['errorMessage'] ?? jsonData['message'] ?? 'API 요청 실패';

        throw ServerException(
          'API 요청 실패 (${response.statusCode}): $errorMessage',
        );
      }
    } on ServerException {
      rethrow;
    }
    // BaseRemoteDataSource에서 NetworkException, ParsingException 처리
  }
}
