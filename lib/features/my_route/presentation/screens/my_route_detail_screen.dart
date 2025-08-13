import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/route_sharing/application/facades/route_sharing_facade.dart';
import 'package:ridingmate/features/route_sharing/di/route_sharing_providers.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/layout/map_with_bottom_sheet_layout.dart';
import 'package:ridingmate/shared/utils/platform_action_sheet.dart';

class MyRouteDetailScreen extends ConsumerWidget {
  const MyRouteDetailScreen({
    super.key,
    required this.routeId,
    required this.userId,
  });

  final String routeId;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SemanticColors colors = context.semanticColor;
    final RouteSharingFacade routeSharingFacade = ref.read(
      routeSharingFacadeProvider,
    );
    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      body: MapWithBottomSheetLayout(
        sheetChild: const SizedBox(height: 240),
        showOptionButton: true,
        onDownloadButtonTap: (BuildContext context) {},
        onShareButtonTap: (BuildContext context) {
          showPlatformActionSheet(
            context,
            title: '공유 방식',
            options: <PlatformActionSheetOption>[
              PlatformActionSheetOption(
                title: '링크로 공유',
                onSelected:
                    () => routeSharingFacade.shareLink(context, routeId),
              ),
              PlatformActionSheetOption(
                title: 'GPX 파일로 공유',
                onSelected:
                    //TODO : 추후 실제 API 요청 로직으로 변경
                    () => routeSharingFacade.shareGpxFromAsset(
                      context,
                      'assets/gpx/sample.gpx',
                    ),
              ),
            ],
          );
        },
        onOptionButtonTap: (BuildContext context) {},
      ),
    );
  }
}
