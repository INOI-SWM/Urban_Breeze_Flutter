import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/workout_history/data/models/integration_authentication_response_model.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

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
}
