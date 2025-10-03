import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/workout_history/domain/entities/apple_health_connection.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

class AppleHealthConnectDataSource extends BaseRemoteDataSource {
  AppleHealthConnectDataSource({super.client});

  /// Apple Health Kit 연동 완료 알림
  Future<AppleHealthConnection> connectAppleHealth() async {
    try {
      final http.Response response = await post(
        ApiEndpoints.appleHealthConnect,
      );
      final Map<String, dynamic> json = decodeResponse(response);
      final Map<String, dynamic> data = json['data'] as Map<String, dynamic>;

      return AppleHealthConnection.fromJson(data);
    } catch (e) {
      throw Exception('Apple Health Kit 연동 알림 중 오류 발생: ${e.toString()}');
    }
  }
}
