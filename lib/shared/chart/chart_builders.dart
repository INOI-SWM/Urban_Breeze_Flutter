import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:urban_breeze/shared/chart/chart_style_config.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';

class ChartBuilders {
  ChartBuilders._();

  /// 공통 FlTitlesData 생성
  ///
  /// [colors]: 시맨틱 컬러
  /// [interval]: Y축 간격
  /// [unit]: Y축 레이블 단위 (예: 'm', 'km/h', '')
  /// [showBottomTitles]: X축 레이블 표시 여부
  static FlTitlesData buildTitlesData({
    required SemanticColors colors,
    required double interval,
    required String unit,
    bool showBottomTitles = false,
    Widget Function(double, TitleMeta)? bottomTitleBuilder,
  }) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: ChartStyleConfig.yAxisReservedSize,
          getTitlesWidget: (double value, TitleMeta meta) {
            if (value % interval != 0) {
              return const SizedBox.shrink();
            }
            return Text(
              '${value.toInt()}$unit',
              style: ChartStyleConfig.getChartLabelStyle(colors),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showBottomTitles,
          getTitlesWidget:
              bottomTitleBuilder ?? (_, __) => const SizedBox.shrink(),
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// 공통 FlGridData 생성
  ///
  /// [colors]: 시맨틱 컬러
  /// [interval]: Y축 격자선 간격
  static FlGridData buildGridData({
    required SemanticColors colors,
    required double interval,
  }) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (double value) {
        return FlLine(
          color: ChartStyleConfig.getGridLineColor(colors),
          strokeWidth: ChartStyleConfig.gridLineWidth,
        );
      },
    );
  }

  /// 공통 FlBorderData 생성 (테두리 없음)
  static FlBorderData buildBorderData() {
    return FlBorderData(show: false);
  }

  /// LineChart용 LineChartBarData 생성
  ///
  /// [spots]: 데이터 포인트들
  /// [color]: 선 색상
  /// [isCurved]: 곡선 여부
  /// [showDots]: 점 표시 여부
  /// [showBelowBar]: 하단 영역 표시 여부
  /// [barWidth]: 선 두께
  static LineChartBarData buildLineChartBarData({
    required List<FlSpot> spots,
    required Color color,
    bool isCurved = true,
    bool showDots = false,
    bool showBelowBar = true,
    double barWidth = 3,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: isCurved,
      color: color,
      barWidth: barWidth,
      isStrokeCapRound: true,
      dotData: FlDotData(show: showDots),
      belowBarData:
          showBelowBar
              ? BarAreaData(show: true, color: color.withValues(alpha: 0.1))
              : BarAreaData(show: false),
    );
  }
}
