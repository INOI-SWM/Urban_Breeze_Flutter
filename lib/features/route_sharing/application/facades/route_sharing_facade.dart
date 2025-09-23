import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/route_sharing/application/use_cases/get_route_share_link_use_case.dart';
import 'package:urban_breeze/features/route_sharing/domain/entities/route_share_link.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class RouteSharingFacade {
  RouteSharingFacade({required this.getRouteShareLinkUseCase});

  final GetRouteShareLinkUseCase getRouteShareLinkUseCase;

  Future<void> shareLink(BuildContext context, String routeId) async {
    final Rect origin = _getSharePositionOrigin(context);

    try {
      final AppResult<RouteShareLink> result = await getRouteShareLinkUseCase
          .execute(routeId);
      if (!context.mounted) return;

      if (result.isFailure) {
        // 링크 공유 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'route_sharing_link_failed',
          properties: <String, dynamic>{
            'route_id': routeId,
            'error_message': result.exceptionOrNull?.message ?? '공유 링크 생성 실패',
          },
        );

        ErrorDisplay.showErrorMessage(
          context,
          result.exceptionOrNull?.message ?? '공유 링크 생성 실패',
        );
        return;
      }

      final RouteShareLink link = result.dataOrNull!;
      await SharePlus.instance.share(
        ShareParams(text: link.url, sharePositionOrigin: origin),
      );

      // 링크 공유 성공 이벤트
      AmplitudeAnalytics.logEvent(
        'route_sharing_link_success',
        properties: <String, dynamic>{
          'route_id': routeId,
          'share_url': link.url,
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
    String routeId,
  ) async {
    final Rect origin = _getSharePositionOrigin(context);

    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'route_$routeId.gpx';
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsString(gpxData);

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
}
