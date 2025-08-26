import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';

/// App Tracking Transparency 서비스
/// iOS 14.5+에서 사용자 추적 권한을 요청하는 서비스
class AppTrackingService {
  AppTrackingService._();
  static AppTrackingService? _instance;

  // 싱글톤 패턴
  static AppTrackingService get instance =>
      _instance ??= AppTrackingService._();

  /// iOS에서만 ATT 권한 요청
  Future<TrackingStatus> requestTrackingAuthorization() async {
    if (!Platform.isIOS) {
      debugPrint('ATT 권한 요청: iOS가 아닌 플랫폼에서는 무시됨');
      return TrackingStatus.notDetermined;
    }

    try {
      debugPrint('ATT 권한 요청 시작');

      // 현재 권한 상태 확인
      final TrackingStatus status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('현재 ATT 권한 상태: $status');

      // 이미 권한이 결정된 경우
      if (status != TrackingStatus.notDetermined) {
        debugPrint('ATT 권한이 이미 결정됨: $status');
        return status;
      }

      // 권한 요청
      final TrackingStatus requestedStatus =
          await AppTrackingTransparency.requestTrackingAuthorization();
      debugPrint('ATT 권한 요청 결과: $requestedStatus');

      return requestedStatus;
    } catch (e) {
      debugPrint('ATT 권한 요청 실패: $e');
      return TrackingStatus.notDetermined;
    }
  }

  /// 현재 권한 상태 확인
  Future<TrackingStatus> getTrackingStatus() async {
    if (!Platform.isIOS) {
      return TrackingStatus.notDetermined;
    }

    try {
      final TrackingStatus status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('현재 ATT 권한 상태: $status');
      return status;
    } catch (e) {
      debugPrint('ATT 권한 상태 확인 실패: $e');
      return TrackingStatus.notDetermined;
    }
  }

  /// 권한 상태를 문자열로 변환
  String getTrackingStatusString(TrackingStatus status) {
    return switch (status) {
      TrackingStatus.notDetermined => 'notDetermined',
      TrackingStatus.restricted => 'restricted',
      TrackingStatus.denied => 'denied',
      TrackingStatus.authorized => 'authorized',
      TrackingStatus.notSupported => 'notSupported',
    };
  }

  /// 권한이 허용되었는지 확인
  bool isTrackingAuthorized(TrackingStatus status) {
    return status == TrackingStatus.authorized;
  }

  /// 현재 권한이 허용되었는지 확인
  Future<bool> isCurrentlyAuthorized() async {
    final TrackingStatus status = await getTrackingStatus();
    return isTrackingAuthorized(status);
  }
}
