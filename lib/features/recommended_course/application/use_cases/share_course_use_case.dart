import 'package:share_plus/share_plus.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';

/// 추천경로 공유 UseCase
class ShareCourseUseCase {
  const ShareCourseUseCase();

  /// GPX 파일 공유
  Future<AppResult<void>> shareGpx(String courseId) async {
    try {
      // GPX 파일 생성
      final String gpxContent = await _generateGpxContent(courseId);

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
      // GPX 파일 생성
      final String gpxContent = await _generateGpxContent(courseId);

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

  /// GPX 파일 내용 생성 (임시 구현)
  Future<String> _generateGpxContent(String courseId) async {
    // 실제로는 서버에서 GPX 데이터를 가져와야 함
    return '''<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="UrbanBreeze">
  <trk>
    <name>추천경로 $courseId</name>
    <trkseg>
      <trkpt lat="37.5665" lon="126.9780">
        <ele>100</ele>
        <time>2024-01-01T00:00:00Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>''';
  }
}
