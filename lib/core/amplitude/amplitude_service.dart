import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/configuration.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Amplitude 서비스 클래스
/// 싱글톤 패턴을 사용하여 앱 전체에서 하나의 인스턴스만 사용
class AmplitudeService {
  AmplitudeService._();
  static AmplitudeService? _instance;
  late final Amplitude _amplitude;
  bool _isInitialized = false;

  // 싱글톤 패턴
  static AmplitudeService get instance => _instance ??= AmplitudeService._();

  /// Amplitude 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String apiKey = dotenv.env['AMPLITUDE_API_KEY'] ?? '';
      if (apiKey.isEmpty) {
        throw Exception('AMPLITUDE_API_KEY가 설정되지 않았습니다.');
      }

      _amplitude = Amplitude(
        Configuration(
          apiKey: apiKey,
          instanceName: 'urban_breeze_dev',
          flushIntervalMillis: 50000,
          flushQueueSize: 20,
        ),
      );

      await _amplitude.isBuilt;
      _isInitialized = true;
    } catch (e) {
      throw Exception('Amplitude 초기화 실패: $e');
    }
  }

  /// 사용자 식별
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) {
      throw Exception('Amplitude가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }

    try {
      await _amplitude.setUserId(userId);
    } catch (e) {
      throw Exception('사용자 ID 설정 실패: $e');
    }
  }

  /// 초기화 상태 확인
  bool get isInitialized => _isInitialized;

  /// Amplitude 인스턴스 접근
  Amplitude get amplitude => _amplitude;
}
