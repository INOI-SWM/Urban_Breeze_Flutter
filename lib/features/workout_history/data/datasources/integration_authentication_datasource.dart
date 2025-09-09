import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/workout_history/data/models/integration_authentication_response_model.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class IntegrationAuthenticationDataSource extends BaseRemoteDataSource {
  IntegrationAuthenticationDataSource({super.client});

  /// 연동 링크 요청
  Future<IntegrationAuthenticationApiResponse> requestIntegrationLink({
    required String terraProvider,
  }) async {
    try {
      final Uri uri = Uri.parse(ApiEndpoints.integrationAuthentication).replace(
        queryParameters: <String, String>{'terraProvider': terraProvider},
      );

      final http.Response response = await post(uri.toString());

      final Map<String, dynamic> responseData = decodeResponse(response);

      return IntegrationAuthenticationApiResponse.fromJson(
        responseData,
        IntegrationAuthenticationResponseModel.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 연동된 서비스들의 활동 기록 가져오기
  Future<ApiResponseModel<Map<String, dynamic>>>
  getIntegrationActivity() async {
    try {
      final Uri uri = Uri.parse(ApiEndpoints.integrationActivity);

      final http.Response response = await get(uri.toString());

      final Map<String, dynamic> responseData = decodeResponse(response);

      return ApiResponseModel<Map<String, dynamic>>.fromJson(
        responseData,
        (Map<String, dynamic> json) => json,
      );
    } catch (e) {
      rethrow;
    }
  }
}
