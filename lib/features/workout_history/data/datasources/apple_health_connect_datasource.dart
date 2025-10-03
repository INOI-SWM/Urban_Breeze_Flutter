import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

class AppleHealthConnectDataSource extends BaseRemoteDataSource {
  AppleHealthConnectDataSource({super.client});

  /// Apple Health Kit 연동 완료 알림
  Future<void> connectAppleHealth() async {
    try {
      await post(ApiEndpoints.appleHealthConnect);
    } catch (e) {
      throw Exception('Apple Health Kit 연동 알림 중 오류 발생: ${e.toString()}');
    }
  }
}
