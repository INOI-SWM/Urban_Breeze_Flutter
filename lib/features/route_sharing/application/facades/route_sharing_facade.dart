import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/config/environment_config.dart';
import 'package:urban_breeze/features/route_sharing/application/use_cases/get_route_share_link_use_case.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class RouteSharingFacade {
  RouteSharingFacade({required this.getRouteShareLinkUseCase});

  final GetRouteShareLinkUseCase getRouteShareLinkUseCase;

  Future<void> shareLink(BuildContext context, String routeId) async {
    final Rect origin = _getSharePositionOrigin(context);

    try {
      // 유니버셜 링크 생성 (통합 share 엔드포인트 사용)
      final String universalLink =
          '${EnvironmentConfig.shareBaseUrl}/share?type=route&id=$routeId';

      await SharePlus.instance.share(
        ShareParams(
          text: '어반브리즈에서 공유된 경로를 확인해주세요! \n $universalLink',
          sharePositionOrigin: origin,
        ),
      );

      // 링크 공유 성공 이벤트
      AmplitudeAnalytics.logEvent(
        'route_sharing_link_success',
        properties: <String, dynamic>{
          'route_id': routeId,
          'share_url': universalLink,
          'link_type': 'universal_link',
          'share_type': 'route',
        },
      );
    } catch (e) {
      // 링크 공유 예외 이벤트
      AmplitudeAnalytics.logEvent(
        'route_sharing_link_exception',
        properties: <String, dynamic>{
          'route_id': routeId,
          'error_message': e.toString(),
        },
      );

      if (!context.mounted) return;
      ErrorDisplay.showErrorMessage(context, '공유 링크 생성 실패: ${e.toString()}');
    }
  }

  Rect _getSharePositionOrigin(BuildContext context) {
    final RenderObject? ro = context.findRenderObject();
    if (ro is RenderBox && ro.hasSize) {
      return ro.localToGlobal(Offset.zero) & ro.size;
    }
    final Size size = MediaQuery.of(context).size;
    return Rect.fromLTWH(0, 0, size.width, kToolbarHeight);
  }

  Future<void> shareGpxFromAsset(BuildContext context, String assetPath) async {
    final Rect origin = _getSharePositionOrigin(context);

    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = assetPath.split('/').last;
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(data.buffer.asUint8List());

      if (!context.mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          text: '라이딩 경로 GPX 파일입니다.',
          files: <XFile>[XFile(file.path, mimeType: 'application/gpx+xml')],
          sharePositionOrigin: origin,
        ),
      );

      // GPX 공유 성공 이벤트
      AmplitudeAnalytics.logEvent(
        'route_sharing_gpx_success',
        properties: <String, dynamic>{
          'asset_path': assetPath,
          'file_name': fileName,
        },
      );
    } catch (e) {
      // GPX 공유 실패 이벤트
      AmplitudeAnalytics.logEvent(
        'route_sharing_gpx_failed',
        properties: <String, dynamic>{
          'asset_path': assetPath,
          'error_message': e.toString(),
        },
      );

      if (!context.mounted) return;
      ErrorDisplay.showErrorMessage(context, 'GPX 공유 실패: ${e.toString()}');
    }
  }

  Future<void> shareGpxFromData(
    BuildContext context,
    String gpxData,
    String routeId, {
    String? routeTitle,
  }) async {
    final Rect origin = _getSharePositionOrigin(context);

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = _generateGpxFileName(routeId, routeTitle);
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsString(gpxData);

      if (!context.mounted) return;

      final String shareTitle =
          routeTitle?.isNotEmpty == true ? routeTitle! : '라이딩 경로 GPX 파일';

      await SharePlus.instance.share(
        ShareParams(
          title: shareTitle,
          files: <XFile>[XFile(file.path, mimeType: 'application/gpx+xml')],
          sharePositionOrigin: origin,
        ),
      );

      // GPX 공유 성공 이벤트
      AmplitudeAnalytics.logEvent(
        'route_sharing_gpx_success',
        properties: <String, dynamic>{
          'route_id': routeId,
          'file_name': fileName,
        },
      );
    } catch (e) {
      // GPX 공유 실패 이벤트
      AmplitudeAnalytics.logEvent(
        'route_sharing_gpx_failed',
        properties: <String, dynamic>{
          'route_id': routeId,
          'error_message': e.toString(),
        },
      );

      if (!context.mounted) return;
      ErrorDisplay.showErrorMessage(context, 'GPX 공유 실패: ${e.toString()}');
    }
  }

  Future<void> shareTcxFromData(
    BuildContext context,
    String tcxData,
    String routeId, {
    String? routeTitle,
  }) async {
    final Rect origin = _getSharePositionOrigin(context);

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = _generateTcxFileName(routeId, routeTitle);
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsString(tcxData);

      if (!context.mounted) return;

      final String shareTitle =
          routeTitle?.isNotEmpty == true ? routeTitle! : '라이딩 경로 TCX 파일';

      await SharePlus.instance.share(
        ShareParams(
          title: shareTitle,
          files: <XFile>[XFile(file.path, mimeType: 'application/tcx+xml')],
          sharePositionOrigin: origin,
        ),
      );

      // TCX 공유 성공 이벤트
      AmplitudeAnalytics.logEvent(
        'route_sharing_tcx_success',
        properties: <String, dynamic>{
          'route_id': routeId,
          'file_name': fileName,
        },
      );
    } catch (e) {
      // TCX 공유 실패 이벤트
      AmplitudeAnalytics.logEvent(
        'route_sharing_tcx_failed',
        properties: <String, dynamic>{
          'route_id': routeId,
          'error_message': e.toString(),
        },
      );

      if (!context.mounted) return;
      ErrorDisplay.showErrorMessage(context, 'TCX 공유 실패: ${e.toString()}');
    }
  }

  String _generateGpxFileName(String routeId, String? routeTitle) {
    if (routeTitle != null && routeTitle.isNotEmpty) {
      // 파일명에 사용할 수 없는 문자들 제거/변경
      final String cleanTitle =
          routeTitle
              .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
              .replaceAll(' ', '_')
              .trim();

      // 파일명이 너무 길면 자르기 (확장자 포함 255자 제한)
      final String truncatedTitle =
          cleanTitle.length > 200 ? cleanTitle.substring(0, 200) : cleanTitle;

      return '$truncatedTitle.gpx';
    }

    // 제목이 없는 경우에만 route_id 사용
    return 'route_$routeId.gpx';
  }

  String _generateTcxFileName(String routeId, String? routeTitle) {
    if (routeTitle != null && routeTitle.isNotEmpty) {
      // 파일명에 사용할 수 없는 문자들 제거/변경
      final String cleanTitle =
          routeTitle
              .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
              .replaceAll(' ', '_')
              .trim();

      // 파일명이 너무 길면 자르기 (확장자 포함 255자 제한)
      final String truncatedTitle =
          cleanTitle.length > 200 ? cleanTitle.substring(0, 200) : cleanTitle;

      return '$truncatedTitle.tcx';
    }

    // 제목이 없는 경우에만 route_id 사용
    return 'route_$routeId.tcx';
  }
}
