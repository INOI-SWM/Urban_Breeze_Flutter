import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';

class ChartStyleConfig {
  ChartStyleConfig._();

  static Color getGridLineColor(SemanticColors colors) =>
      colors.lineNormalNeutral.withValues(alpha: 0.3);

  static TextStyle getAxisLabelStyle(SemanticColors colors) =>
      AppTextStyles.caption2.regular.copyWith(color: colors.labelAlternative);

  static TextStyle getChartLabelStyle(SemanticColors colors) =>
      TextStyle(color: colors.labelAlternative, fontSize: 12);

  static Color getTooltipTextColor(SemanticColors colors) => colors.staticWhite;

  static const double gridLineWidth = 1.0;
  static const double yAxisReservedSize = 40.0;
  static const double topPaddingRatio = 0.1;
  static const double reservedSizePadding = 8.0;
}
