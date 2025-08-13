import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/layout/map_with_bottom_sheet_layout.dart';
import 'package:ridingmate/shared/route_sharing/application/services/share_service.dart';
import 'package:ridingmate/shared/utils/platform_action_sheet.dart';

class MyRouteDetailScreen extends StatelessWidget {
  const MyRouteDetailScreen({
    super.key,
    required this.routeId,
    required this.userId,
  });

  final String routeId;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
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
                onSelected: () => shareRouteLink(context, userId, routeId),
              ),
              PlatformActionSheetOption(
                title: 'GPX 파일로 공유',
                onSelected: () async {
                  // TODO: 추후 실제 API 요청 로직으로 변경
                },
              ),
            ],
          );
        },
        onOptionButtonTap: (BuildContext context) {},
      ),
    );
  }
}
