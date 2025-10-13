import 'package:terra_flutter_bridge/models/enums.dart';

/// Terra SDK를 통한 헬스 데이터 관리 Repository
abstract class TerraRepository {
  /// Terra SDK 초기화
  Future<void> initializeTerra();

  /// 헬스 앱 연결 (권한 요청)
  Future<void> connectHealthApp(Connection connection);

  /// 헬스 데이터 가져오기
  Future<Map<String, dynamic>?> getHealthData({
    required Connection connection,
    required DateTime startDate,
    required DateTime endDate,
    bool toWebhook = true,
  });
}
