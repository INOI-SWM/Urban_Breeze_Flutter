import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/chart/chart_axis_utils.dart';
import 'package:urban_breeze/shared/chart/chart_builders.dart';
import 'package:urban_breeze/shared/chart/chart_style_config.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';

class CommonLineChartWidget extends StatelessWidget {
  const CommonLineChartWidget({
    super.key,
    required this.title,
    required this.spots,
    required this.unit,
    required this.color,
    this.emptyMessage = '데이터가 없습니다',
    this.height = 200,
    this.showTooltip = false,
    this.barWidth = 3,
    this.isCurved = true,
    this.showBelowBar = true,
  });

  final String title;
  final List<FlSpot> spots;
  final String unit;
  final Color color;
  final String emptyMessage;
  final double height;
  final bool showTooltip;
  final double barWidth;
  final bool isCurved;
  final bool showBelowBar;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    if (spots.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            emptyMessage,
            style: AppTextStyles.body2.readingMedium.copyWith(
              color: colors.labelAlternative,
            ),
          ),
        ),
      );
    }

    final double minValue = ChartAxisUtils.getMinValue(
      spots,
      (FlSpot spot) => spot.y,
    );
    final double maxValue = ChartAxisUtils.getMaxValue(
      spots,
      (FlSpot spot) => spot.y,
    );
    final double range = maxValue - minValue;
    final double interval = ChartAxisUtils.calculateInterval(range);
    final double chartMinY = ChartAxisUtils.calculateChartMinY(
      minValue,
      interval,
    );
    final double chartMaxY = ChartAxisUtils.calculateChartMaxY(
      maxValue,
      interval,
    );

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: AppTextStyles.heading2.bold.copyWith(
              color: colors.labelStrong,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: chartMinY,
                maxY: chartMaxY,
                gridData: ChartBuilders.buildGridData(
                  colors: colors,
                  interval: interval,
                ),
                titlesData: ChartBuilders.buildTitlesData(
                  colors: colors,
                  interval: interval,
                  unit: unit,
                ),
                borderData: ChartBuilders.buildBorderData(),
                lineTouchData:
                    showTooltip
                        ? LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (List<LineBarSpot> touchedSpots) {
                              return touchedSpots.map((
                                LineBarSpot touchedSpot,
                              ) {
                                return LineTooltipItem(
                                  '${touchedSpot.y.toInt()}$unit',
                                  AppTextStyles.caption2.regular.copyWith(
                                    color: ChartStyleConfig.getTooltipTextColor(
                                      colors,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        )
                        : const LineTouchData(enabled: false),
                lineBarsData: <LineChartBarData>[
                  ChartBuilders.buildLineChartBarData(
                    spots: spots,
                    color: color,
                    barWidth: barWidth,
                    isCurved: isCurved,
                    showBelowBar: showBelowBar,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
