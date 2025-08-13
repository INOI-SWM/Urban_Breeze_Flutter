import 'package:flutter/material.dart';
import 'package:ridingmate/core/result/app_result.dart';
import 'package:ridingmate/features/route_sharing/application/use_cases/get_route_share_link_use_case.dart';
import 'package:ridingmate/features/route_sharing/domain/entities/route_share_link.dart';
import 'package:ridingmate/shared/mixins/error_display_mixin.dart';
import 'package:share_plus/share_plus.dart';

class RouteSharingFacade {
  RouteSharingFacade({required this.getRouteShareLinkUseCase});

  final GetRouteShareLinkUseCase getRouteShareLinkUseCase;

  Future<void> shareLink(BuildContext context, String routeId) async {
    final Rect origin = _getSharePositionOrigin(context);
    final AppResult<RouteShareLink> result = await getRouteShareLinkUseCase
        .execute(routeId);
    if (!context.mounted) return;
    if (result.isFailure) {
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
  }

  Rect _getSharePositionOrigin(BuildContext context) {
    final RenderObject? ro = context.findRenderObject();
    if (ro is RenderBox && ro.hasSize) {
      return ro.localToGlobal(Offset.zero) & ro.size;
    }
    final Size size = MediaQuery.of(context).size;
    return Rect.fromLTWH(0, 0, size.width, kToolbarHeight);
  }
}
