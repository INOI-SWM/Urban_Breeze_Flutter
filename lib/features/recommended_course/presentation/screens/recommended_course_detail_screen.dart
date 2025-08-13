import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/layout/map_with_bottom_sheet_layout.dart';

class RecommendedCourseDetailScreen extends StatelessWidget {
  const RecommendedCourseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      body: MapWithBottomSheetLayout(
        sheetChild: const SizedBox(height: 240),
        onDownloadButtonTap: (BuildContext context) {},
        onShareButtonTap: (BuildContext context) {},
      ),
    );
  }
}
