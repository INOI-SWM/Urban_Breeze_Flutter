import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 타입
enum Environment { dev, staging, prod }

/// 환경 설정 관리 클래스
class EnvironmentConfig {
  EnvironmentConfig._();

  static Environment _environment = Environment.dev;

  /// 현재 환경
  static Environment get environment => _environment;

  /// 환경 초기화
  static Future<void> initialize({required Environment env}) async {
    _environment = env;

    // 환경별 .env 파일 로드
    final String envFile = _getEnvFileName(env);
    await dotenv.load(fileName: envFile);
  }

  /// 환경별 .env 파일명 반환
  static String _getEnvFileName(Environment env) {
    switch (env) {
      case Environment.dev:
        return '.env.dev';
      case Environment.staging:
        return '.env.staging';
      case Environment.prod:
        return '.env.prod';
    }
  }

  /// API Base URL
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';

  /// Terra Dev ID
  static String get terraDevId => dotenv.env['TERRA_DEV_ID'] ?? '';

  /// Kakao Native App Key
  static String get kakaoNativeAppKey =>
      dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';

  /// Google Maps API Key
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Amplitude API Key
  static String get amplitudeApiKey => dotenv.env['AMPLITUDE_API_KEY'] ?? '';

  /// 환경 이름
  static String get envName => dotenv.env['ENV_NAME'] ?? 'unknown';

  /// 개발 환경 여부
  static bool get isDev => _environment == Environment.dev;

  /// 스테이징 환경 여부
  static bool get isStaging => _environment == Environment.staging;

  /// 프로덕션 환경 여부
  static bool get isProd => _environment == Environment.prod;

  /// 앱 표시 이름
  static String get appDisplayName {
    switch (_environment) {
      case Environment.dev:
        return 'Urban Breeze Dev';
      case Environment.staging:
        return 'Urban Breeze Staging';
      case Environment.prod:
        return 'Urban Breeze';
    }
  }
}
