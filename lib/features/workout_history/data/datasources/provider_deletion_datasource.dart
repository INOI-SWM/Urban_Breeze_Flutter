import 'package:http/http.dart' as http;
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

class ProviderDeletionDataSource extends BaseRemoteDataSource {
  ProviderDeletionDataSource({super.client});

  /// 특정 제공자 삭제
  Future<void> deleteProvider(String providerName) async {
    try {
      final http.Response response = await delete(
        ApiEndpoints.deleteProvider(providerName),
      );

      final int statusCode = response.statusCode;
      if (statusCode == 200 || statusCode == 204) {
        return;
      }
      throw Exception('제공자 삭제 실패: $statusCode');
    } catch (e) {
      throw Exception('제공자 삭제 중 오류 발생: ${e.toString()}');
    }
  }
}
