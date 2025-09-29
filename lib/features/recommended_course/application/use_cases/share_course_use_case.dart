import 'package:share_plus/share_plus.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/domain/repositories/recommended_course_repository.dart';

/// 추천경로 공유 UseCase
class ShareCourseUseCase {
  const ShareCourseUseCase({required RecommendedCourseRepository repository})
    : _repository = repository;

  final RecommendedCourseRepository _repository;

  /// GPX 파일 공유
  Future<AppResult<void>> shareGpx(String courseId) async {
    try {
      // GPX 파일 생성 (API 호출)
      final String gpxContent = await _repository.getCourseGPX(courseId);

      // GPX 파일 공유
      await SharePlus.instance.share(ShareParams(text: gpxContent));

      // GPX 공유 성공 이벤트
      AmplitudeAnalytics.logEvent(
        'recommended_course_gpx_share_success',
        properties: <String, dynamic>{'course_id': courseId},
      );

      return const AppSuccess<void>(null);
    } catch (e) {
      // GPX 공유 실패 이벤트
      AmplitudeAnalytics.logEvent(
        'recommended_course_gpx_share_failed',
        properties: <String, dynamic>{
          'course_id': courseId,
          'error_message': e.toString(),
        },
      );

      return AppFailure<void>(ServerException('GPX 공유 실패: ${e.toString()}'));
    }
  }

  /// GPX 파일 다운로드
  Future<AppResult<void>> downloadGpx(String courseId) async {
    try {
      // GPX 파일 생성 (API 호출)
      final String gpxContent = await _repository.getCourseGPX(courseId);

      // GPX 파일 다운로드
      await SharePlus.instance.share(ShareParams(text: gpxContent));

      // GPX 다운로드 성공 이벤트
      AmplitudeAnalytics.logEvent(
        'recommended_course_gpx_download_success',
        properties: <String, dynamic>{'course_id': courseId},
      );

      return const AppSuccess<void>(null);
    } catch (e) {
      // GPX 다운로드 실패 이벤트
      AmplitudeAnalytics.logEvent(
        'recommended_course_gpx_download_failed',
        properties: <String, dynamic>{
          'course_id': courseId,
          'error_message': e.toString(),
        },
      );

      return AppFailure<void>(ServerException('GPX 다운로드 실패: ${e.toString()}'));
    }
  }

  /// 딥링크 공유
  Future<AppResult<String>> shareDeepLink(String courseId) async {
    try {
      // 딥링크 생성
      final String deepLink = 'urbanbreeze://course?courseId=$courseId';
      return AppSuccess<String>(deepLink);
    } catch (e) {
      return AppFailure<String>(ServerException('딥링크 공유 실패: ${e.toString()}'));
    }
  }

  /// 딥링크 공유 (메시지와 함께)
  Future<AppResult<void>> shareDeepLinkWithMessage(String courseId) async {
    try {
      // 딥링크 생성
      final String deepLink = 'urbanbreeze://course?courseId=$courseId';
      final String shareMessage = '어반브리즈에서 추천하는 경로를 확인해보세요!\n$deepLink';

      // 딥링크 공유
      await SharePlus.instance.share(ShareParams(text: shareMessage));

      // 공유 성공 이벤트
      AmplitudeAnalytics.logEvent(
        'recommended_course_share_success',
        properties: <String, dynamic>{
          'course_id': courseId,
          'share_url': deepLink,
        },
      );

      return const AppSuccess<void>(null);
    } catch (e) {
      // 공유 실패 이벤트
      AmplitudeAnalytics.logEvent(
        'recommended_course_share_failed',
        properties: <String, dynamic>{
          'course_id': courseId,
          'error_message': e.toString(),
        },
      );

      return AppFailure<void>(ServerException('딥링크 공유 실패: ${e.toString()}'));
    }
  }
}
