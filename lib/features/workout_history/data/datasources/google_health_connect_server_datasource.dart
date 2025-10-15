import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

class GoogleHealthConnectServerDataSource extends BaseRemoteDataSource {
  GoogleHealthConnectServerDataSource({super.client});

  /// Google Health Connect 연동 완료 알림
  Future<void> connectGoogleHealthConnect() async {
    try {
      await post(ApiEndpoints.googleHealthConnect);
    } catch (e) {
      throw Exception('Google Health Connect 연동 알림 중 오류 발생: ${e.toString()}');
    }
  }
}
