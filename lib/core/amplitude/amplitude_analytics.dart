import 'package:amplitude_flutter/events/base_event.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'amplitude_events.dart';
import 'amplitude_providers.dart';
import 'amplitude_service.dart';

/// Amplitude 분석 유틸리티
/// 간단한 이벤트 전송 기능 제공
class AmplitudeAnalytics {
  /// 이벤트 전송
  static Future<void> logEvent(
    WidgetRef ref,
    String eventName, {
    Map<String, dynamic>? properties,
  }) async {
    final AmplitudeService amplitudeService = ref.read(
      amplitudeServiceProvider,
    );

    try {
      final BaseEvent event = BaseEvent(eventName, eventProperties: properties);
      await amplitudeService.amplitude.track(event);
    } catch (e) {
      debugPrint('Amplitude 이벤트 전송 실패: $e');
    }
  }

  /// 화면 조회 이벤트 전송
  static Future<void> logScreenView(
    WidgetRef ref,
    String screenName, {
    Map<String, dynamic>? additionalProperties,
  }) async {
    final Map<String, dynamic> properties = <String, dynamic>{
      'screen_name': screenName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?additionalProperties,
    };

    await logEvent(ref, AmplitudeEvents.screenViewed, properties: properties);
  }

  /// 버튼 클릭 이벤트 전송
  static Future<void> logButtonClick(
    WidgetRef ref,
    String buttonName, {
    Map<String, dynamic>? additionalProperties,
  }) async {
    final Map<String, dynamic> properties = <String, dynamic>{
      'button_name': buttonName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?additionalProperties,
    };

    await logEvent(ref, AmplitudeEvents.buttonClicked, properties: properties);
  }

  /// 사용자 ID 설정
  static Future<void> setUserId(WidgetRef ref, String userId) async {
    final AmplitudeService amplitudeService = ref.read(
      amplitudeServiceProvider,
    );

    try {
      await amplitudeService.setUserId(userId);
    } catch (e) {
      debugPrint('Amplitude 사용자 ID 설정 실패: $e');
    }
  }

  /// 이벤트 플러시 (강제 전송)
  static Future<void> flush(WidgetRef ref) async {
    final AmplitudeService amplitudeService = ref.read(
      amplitudeServiceProvider,
    );

    try {
      await amplitudeService.amplitude.flush();
    } catch (e) {
      debugPrint('Amplitude 이벤트 플러시 실패: $e');
    }
  }
}
