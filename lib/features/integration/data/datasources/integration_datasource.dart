import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/features/integration/data/models/integration_response_model.dart';
import 'package:urban_breeze/features/integration/domain/entities/sync_status.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class IntegrationDataSource extends BaseRemoteDataSource {
  IntegrationDataSource({super.client});

  /// 연동 링크 요청
  Future<IntegrationApiResponse> requestIntegrationLink({
    required String terraProvider,
  }) async {
    try {
      final Uri uri = Uri.parse(ApiEndpoints.integrationAuthentication).replace(
        queryParameters: <String, String>{'terraProvider': terraProvider},
      );

      final http.Response response = await post(uri.toString());

      final Map<String, dynamic> responseData = decodeResponse(response);

      return IntegrationApiResponse.fromJson(
        responseData,
        IntegrationResponseModel.fromJson,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 연동된 서비스들의 활동 기록 가져오기
  Future<ApiResponseModel<Map<String, dynamic>>>
  getIntegrationActivity() async {
    final Uri uri = Uri.parse(ApiEndpoints.integrationActivity);

    final http.Response response = await get(uri.toString());

    final Map<String, dynamic> responseData = decodeResponse(response);

    return ApiResponseModel<Map<String, dynamic>>.fromJson(
      responseData,
      (Map<String, dynamic> json) => json,
    );
  }

  /// Terra 동기화 상태 조회
  Future<SyncStatus> getSyncStatus() async {
    try {
      final Uri uri = Uri.parse(ApiEndpoints.integrationActivitySyncStatus);

      final http.Response response = await get(uri.toString());

      // 404 처리
      if (response.statusCode == 404) {
        throw const SyncJobNotFoundException('동기화 작업을 찾을 수 없습니다.');
      }

      final Map<String, dynamic> responseData = decodeResponse(response);

      // API 응답 구조: { "success": true, "data": { ... } }
      final Map<String, dynamic> data =
          responseData['data'] as Map<String, dynamic>;

      return SyncStatus.fromJson(data);
    } catch (e) {
      if (e is SyncJobNotFoundException) {
        rethrow;
      }
      throw IntegrationException('동기화 상태 조회 실패: $e');
    }
  }
}
