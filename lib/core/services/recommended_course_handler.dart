import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/services/deep_link_service.dart';
import 'package:urban_breeze/features/recommended_course/presentation/screens/recommended_course_detail_screen.dart';

/// 추천경로 딥링크 핸들러
class RecommendedCourseHandler {
  factory RecommendedCourseHandler() => _instance;
  RecommendedCourseHandler._internal();
  static final RecommendedCourseHandler _instance =
      RecommendedCourseHandler._internal();

  /// 추천경로 딥링크 진입 추적
  Future<void> _trackDeepLinkEntry(String courseId) async {
    try {
      // Amplitude에 이벤트 전송
      await AmplitudeAnalytics.logEvent(
        'recommended_course_deep_link_received',
        properties: <String, dynamic>{
          'course_id': courseId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // 딥링크 추적 실패해도 메인 기능은 계속 진행
    }
  }

  static void initialize(WidgetRef ref, BuildContext context) {
    try {
      DeepLinkService().recommendedCourseStream.listen(
        (RecommendedCourseCallback callback) {
          if (!context.mounted) return;
          _instance._handleRecommendedCourseShare(ref, context, callback);
        },
        onError: (Object error) {
          // 딥링크 스트림 오류 처리
        },
      );
    } catch (e) {
      // 초기화 오류 처리
    }
  }

  Future<void> _handleRecommendedCourseShare(
    WidgetRef ref,
    BuildContext context,
    RecommendedCourseCallback callback,
  ) async {
    try {
      if (!callback.isValid) return;

      // 딥링크 진입 추적
      await _trackDeepLinkEntry(callback.courseId);

      // 추천경로 상세 화면으로 이동
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder:
                (BuildContext context) =>
                    RecommendedCourseDetailScreen(routeId: callback.courseId),
          ),
        );
      }
    } catch (e) {
      // 딥링크 처리 실패 시 무시
    }
  }
}
