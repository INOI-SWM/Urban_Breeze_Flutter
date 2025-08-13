import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/layout/map_with_bottom_sheet_layout.dart';
import 'package:ridingmate/shared/utils/platform_action_sheet.dart';

class RecommendedCourseDetailScreen extends StatelessWidget {
  const RecommendedCourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      body: MapWithBottomSheetLayout(
        sheetChild: const SizedBox(height: 240),
        onDownloadButtonTap: (BuildContext context) {
          showPlatformActionSheet(
            context,
            title: '저장 방식',
            options: <PlatformActionSheetOption>[
              PlatformActionSheetOption(title: '나의 경로에 저장', onSelected: () {}),
              PlatformActionSheetOption(title: 'GPX 다운로드', onSelected: () {}),
            ],
          );
        },
        onShareButtonTap: (BuildContext context) {
          showPlatformActionSheet(
            context,
            title: '공유 방식',
            options: <PlatformActionSheetOption>[
              PlatformActionSheetOption(title: '링크로 공유', onSelected: () {}),
              PlatformActionSheetOption(title: 'GPX 파일로 공유', onSelected: () {}),
            ],
          );
        },
      ),
    );
  }
}
