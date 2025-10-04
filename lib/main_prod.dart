import 'package:urban_breeze/core/config/environment_config.dart';
import 'package:urban_breeze/main.dart' as main_app;

/// 프로덕션 환경 진입점
Future<void> main() async {
  // 프로덕션 환경 초기화
  await EnvironmentConfig.initialize(env: Environment.prod);

  // 메인 앱 실행
  await main_app.main();
}
