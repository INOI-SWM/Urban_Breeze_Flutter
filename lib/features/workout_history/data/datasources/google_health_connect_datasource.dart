import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/exceptions/google_health_connect_exceptions.dart';

class GoogleHealthConnectDataSource {
  GoogleHealthConnectDataSource();

  static const MethodChannel _channel = MethodChannel('health_connect');

  /// 사용자에게 Health Connect 권한을 요청
  /// 권한이 없으면 Health Connect 설정 화면으로 리다이렉트
  Future<bool> requestPermissions() async {
    try {
      final String result = await _channel.invokeMethod('requestPermissions');
      debugPrint('Permission request result: $result');

      // SUCCESS 또는 PLAY_STORE_REDIRECT는 권한 요청이 성공한 것으로 간주
      return result == 'SUCCESS' || result == 'PLAY_STORE_REDIRECT';
    } catch (e) {
      debugPrint('Permission request error: $e');

      // Android API 레벨이 낮은 경우 특별 처리
      if (e.toString().contains('API_LEVEL_TOO_LOW')) {
        throw const GoogleHealthConnectException(
          'Health Connect는 Android 8.0(API 26) 이상이 필요합니다.',
        );
      }

      throw GoogleHealthConnectException('권한 요청 실패: $e');
    }
  }

  Future<bool> hasPermissions() async {
    try {
      final bool hasPermissions = await _channel.invokeMethod('hasPermissions');
      return hasPermissions;
    } catch (e) {
      throw GoogleHealthConnectException('권한 상태 확인 실패: $e');
    }
  }

  /// 현재 기기에서 Health Connect를 사용할 수 있는지 확인
  Future<bool> isAvailable() async {
    try {
      final bool isAvailable = await _channel.invokeMethod('isAvailable');
      return isAvailable;
    } catch (e) {
      throw GoogleHealthConnectException('Health Connect 가용성 확인 실패: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCyclingWorkouts({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final DateTime end = endDate ?? DateTime.now();
      final DateTime start =
          startDate ?? end.subtract(const Duration(days: 365));

      final List<dynamic> sessions = await _channel
          .invokeMethod('getExerciseSessions', <String, int>{
            'startTime': start.millisecondsSinceEpoch,
            'endTime': end.millisecondsSinceEpoch,
          });

      final List<Map<String, dynamic>> workouts =
          sessions
              .map((dynamic session) => Map<String, dynamic>.from(session))
              .toList();

      return workouts;
    } catch (e) {
      throw GoogleHealthConnectException('자전거 운동 데이터 조회 실패: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getHeartRateDataForWorkout({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  }) async {
    try {
      final List<dynamic> heartRateData = await _channel
          .invokeMethod('getHeartRateData', <String, int>{
            'startTime': workoutStartTime.millisecondsSinceEpoch,
            'endTime': workoutEndTime.millisecondsSinceEpoch,
          });

      debugPrint('heartRateData: $heartRateData');

      final List<Map<String, dynamic>> data =
          heartRateData
              .map((dynamic item) => Map<String, dynamic>.from(item))
              .toList();

      data.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final int aTime = a['timestamp'] as int;
        final int bTime = b['timestamp'] as int;
        return aTime.compareTo(bTime);
      });

      return data;
    } catch (e) {
      throw GoogleHealthConnectException('심박수 데이터 조회 실패: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getDistanceDataForWorkout({
    required DateTime workoutStartTime,
    required DateTime workoutEndTime,
  }) async {
    try {
      final List<dynamic> distanceData = await _channel
          .invokeMethod('getDistanceData', <String, int>{
            'startTime': workoutStartTime.millisecondsSinceEpoch,
            'endTime': workoutEndTime.millisecondsSinceEpoch,
          });

      final List<Map<String, dynamic>> data =
          distanceData
              .map((dynamic item) => Map<String, dynamic>.from(item))
              .toList();

      data.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final int aTime = a['timestamp'] as int;
        final int bTime = b['timestamp'] as int;
        return aTime.compareTo(bTime);
      });

      return data;
    } catch (e) {
      throw GoogleHealthConnectException('거리 데이터 조회 실패: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLocationDataForSession({
    required String sessionId,
  }) async {
    try {
      final List<dynamic> locationData = await _channel.invokeMethod(
        'getLocationDataForSession',
        <String, String>{'sessionId': sessionId},
      );

      debugPrint('locationData for session $sessionId: $locationData');

      final List<Map<String, dynamic>> data =
          locationData
              .map((dynamic item) => Map<String, dynamic>.from(item))
              .toList();

      data.sort((Map<String, dynamic> a, Map<String, dynamic> b) {
        final int aTime = a['timestamp'] as int;
        final int bTime = b['timestamp'] as int;
        return aTime.compareTo(bTime);
      });

      return data;
    } catch (e) {
      // 권한 관련 에러인지 확인
      if (e.toString().contains('ConsentRequired') ||
          e.toString().contains('permission') ||
          e.toString().contains('consent')) {
        debugPrint('Location data consent required for session $sessionId');
        // 권한이 필요한 경우 빈 리스트 반환 (에러가 아님)
        return <Map<String, dynamic>>[];
      }
      throw GoogleHealthConnectException('세션별 위치 데이터 조회 실패: $e');
    }
  }
}
