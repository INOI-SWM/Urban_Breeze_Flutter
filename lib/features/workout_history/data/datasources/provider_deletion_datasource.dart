import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

class ProviderDeletionDataSource extends BaseRemoteDataSource {
  ProviderDeletionDataSource({super.client});

  /// 특정 제공자 삭제
  Future<void> deleteProvider(String providerName) async {
    try {
      await delete(ApiEndpoints.deleteProvider(providerName));
    } catch (e) {
      throw Exception('제공자 삭제 중 오류 발생: ${e.toString()}');
    }
  }
}
