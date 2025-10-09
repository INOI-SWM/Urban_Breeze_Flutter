import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/integration/domain/entities/api_usage.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

class ApiUsageDataSource extends BaseRemoteDataSource {
  ApiUsageDataSource({super.client});

  /// API 사용량 조회
  Future<ApiUsage> getApiUsage() async {
    try {
      final http.Response response = await get(ApiEndpoints.apiUsage);
      final Map<String, dynamic> json = decodeResponse(response);
      final Map<String, dynamic> data = json['data'] as Map<String, dynamic>;

      return ApiUsage.fromJson(data);
    } catch (e) {
      throw Exception('API 사용량 조회 중 오류 발생: ${e.toString()}');
    }
  }
}
