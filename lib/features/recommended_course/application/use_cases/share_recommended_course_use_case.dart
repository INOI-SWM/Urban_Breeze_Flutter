import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/config/environment_config.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/get_course_gpx_use_case.dart';
import 'package:urban_breeze/features/recommended_course/application/use_cases/get_course_tcx_use_case.dart';
import 'package:urban_breeze/features/route_sharing/application/facades/route_sharing_facade.dart';

/// 추천경로 공유 UseCase
class ShareRecommendedCourseUseCase {
  const ShareRecommendedCourseUseCase({
    required GetCourseGpxUseCase getCourseGpxUseCase,
    required GetCourseTcxUseCase getCourseTcxUseCase,
    required RouteSharingFacade routeSharingFacade,
  }) : _getCourseGpxUseCase = getCourseGpxUseCase,
       _getCourseTcxUseCase = getCourseTcxUseCase,
       _routeSharingFacade = routeSharingFacade;

  final GetCourseGpxUseCase _getCourseGpxUseCase;
  final GetCourseTcxUseCase _getCourseTcxUseCase;
  final RouteSharingFacade _routeSharingFacade;

  /// 유니버셜 링크 공유
  Future<AppResult<void>> shareDeepLink(
    BuildContext context,
    String courseId,
  ) async {
    try {
      // 유니버셜 링크 생성 (통합 share 엔드포인트 사용)
      final String universalLink =
          '${EnvironmentConfig.shareBaseUrl}/share?type=course&id=$courseId';
      final String shareMessage = '어반브리즈에서 추천하는 경로를 확인해보세요!\n$universalLink';

      // 공유 위치 계산
      final Rect sharePositionOrigin = _getSharePositionOrigin(context);

      // 유니버셜 링크 공유
      await SharePlus.instance.share(
        ShareParams(
          text: shareMessage,
          sharePositionOrigin: sharePositionOrigin,
        ),
      );

      // 공유 성공 이벤트
      AmplitudeAnalytics.logEvent(
        'recommended_course_share_success',
        properties: <String, dynamic>{
          'course_id': courseId,
          'share_url': universalLink,
          'link_type': 'universal_link',
          'share_type': 'course',
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

      return AppFailure<void>(NetworkException('공유 실패: ${e.toString()}'));
    }
  }

  /// GPX 파일 공유
  Future<AppResult<void>> shareGpx(
    BuildContext context,
    String courseId,
    String courseTitle,
  ) async {
    try {
      final AppResult<String> result = await _getCourseGpxUseCase.execute(
        courseId: courseId,
      );

      if (result.isFailure) {
        return AppFailure<void>(
          NetworkException(
            result.exceptionOrNull?.message ?? 'GPX 데이터를 가져올 수 없습니다',
          ),
        );
      }

      final String gpxData = result.dataOrNull!;

      // GPX 파일을 생성해서 공유
      if (!context.mounted) {
        return const AppFailure<void>(NetworkException('다시 시도해주세요.'));
      }

      await _routeSharingFacade.shareGpxFromData(
        context,
        gpxData,
        courseId,
        routeTitle: courseTitle,
      );

      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(NetworkException('GPX 공유 실패: ${e.toString()}'));
    }
  }

  /// GPX 파일 다운로드
  Future<AppResult<void>> downloadGpx(
    BuildContext context,
    String courseId,
    String courseTitle,
  ) async {
    try {
      final AppResult<String> result = await _getCourseGpxUseCase.execute(
        courseId: courseId,
      );

      if (result.isFailure) {
        return AppFailure<void>(
          NetworkException(
            result.exceptionOrNull?.message ?? 'GPX 데이터를 가져올 수 없습니다',
          ),
        );
      }

      final String gpxData = result.dataOrNull!;

      // GPX 파일을 생성해서 다운로드
      if (!context.mounted) {
        return const AppFailure<void>(NetworkException('다시 시도해주세요.'));
      }

      await _routeSharingFacade.shareGpxFromData(
        context,
        gpxData,
        courseId,
        routeTitle: courseTitle,
      );

      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(NetworkException('GPX 다운로드 실패: ${e.toString()}'));
    }
  }

  /// TCX 파일 다운로드
  Future<AppResult<void>> downloadTcx(
    BuildContext context,
    String courseId,
    String courseTitle,
  ) async {
    try {
      final AppResult<String> result = await _getCourseTcxUseCase.execute(
        courseId: courseId,
      );

      if (result.isFailure) {
        return AppFailure<void>(
          NetworkException(
            result.exceptionOrNull?.message ?? 'TCX 데이터를 가져올 수 없습니다',
          ),
        );
      }

      final String tcxData = result.dataOrNull!;

      // TCX 파일을 생성해서 다운로드
      if (!context.mounted) {
        return const AppFailure<void>(NetworkException('다시 시도해주세요.'));
      }

      await _routeSharingFacade.shareTcxFromData(
        context,
        tcxData,
        courseId,
        routeTitle: courseTitle,
      );

      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(NetworkException('TCX 다운로드 실패: ${e.toString()}'));
    }
  }

  /// 공유 위치 계산
  Rect _getSharePositionOrigin(BuildContext context) {
    final RenderObject? ro = context.findRenderObject();
    if (ro is RenderBox && ro.hasSize) {
      return ro.localToGlobal(Offset.zero) & ro.size;
    }
    final Size size = MediaQuery.of(context).size;
    return Rect.fromLTWH(0, 0, size.width, kToolbarHeight);
  }
}
