import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

class IntegrationAuthenticationDataSource extends BaseRemoteDataSource {
  IntegrationAuthenticationDataSource({super.client});

  /// 연동 링크 요청
  Future<Map<String, dynamic>> requestIntegrationLink({
    required String terraProvider,
  }) async {
    try {
      final Uri uri = Uri.parse(ApiEndpoints.integrationAuthentication).replace(
        queryParameters: <String, String>{'terraProvider': terraProvider},
      );

      final http.Response response = await post(uri.toString());

      final Map<String, dynamic> responseData = _parseResponse(response);
      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to request integration link: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
