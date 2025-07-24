import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/info/info_item.dart';
import 'package:ridingmate/shared/design_system/widgets/segmented_control/segmented_control.dart';
import 'package:ridingmate/shared/utils/workout_formatter.dart';

import '../../application/use_cases/get_workout_statistics_use_case.dart';
import '../../di/workout_statistics_providers.dart';
import '../../domain/entities/workout_statistics.dart';
import '../../domain/enums/statistic_enums.dart';

class _UIConstants {
  static const double defaultSpacing = 20.0;
  static const double largeSpacing = 40.0;
  static const double chartHeight = 200.0;
  static const double barWidth = 20.0;
  static const double gridLineWidth = 1.0;
  static const double reservedSizePadding = 8.0;
  static const double topPaddingRatio = 0.1;
  static const EdgeInsets loadingPadding = EdgeInsets.symmetric(vertical: 20);
}

class WorkoutStaticsScreen extends ConsumerStatefulWidget {
  const WorkoutStaticsScreen({super.key});

  @override
  ConsumerState<WorkoutStaticsScreen> createState() =>
      _WorkoutStaticsScreenState();
}

class _WorkoutStaticsScreenState extends ConsumerState<WorkoutStaticsScreen> {
  StatisticPeriodType _selectedPeriodType = StatisticPeriodType.week;
  StaticDataType _selectedDataType = StaticDataType.distance;

  bool _isLoading = false;
  WorkoutStatistics? _currentStatistics;
  String? _error;

  late final GetWorkoutStatisticsUseCase _getWorkoutStatisticsUseCase;

  static const List<StatisticPeriodType> _periodTabs = <StatisticPeriodType>[
    StatisticPeriodType.week,
    StatisticPeriodType.month,
    StatisticPeriodType.year,
    StatisticPeriodType.all,
  ];

  static const List<StaticDataType> _dataTypeTabs = <StaticDataType>[
    StaticDataType.distance,
    StaticDataType.elevation,
    StaticDataType.duration,
  ];

  @override
  void initState() {
    super.initState();
    _getWorkoutStatisticsUseCase = ref.read(
      getWorkoutStatisticsUseCaseProvider,
    );
    _loadStatistics();
  }

  TextStyle get _chartLabelStyle => AppTextStyles.caption2.regular.copyWith(
    color: context.semanticColor.labelAlternative,
  );

  Color get _gridLineColor =>
      context.semanticColor.lineNormalNormal.withValues(alpha: 0.3);

  Color get _barColor => context.semanticColor.primaryNormal;

  Color get _tooltipTextColor => context.semanticColor.staticWhite;

  TextStyle get _titleStyle => AppTextStyles.title3.bold.copyWith(
    color: context.semanticColor.labelStrong,
  );

  TextStyle get _labelStyle => AppTextStyles.label1.normalBold.copyWith(
    color: context.semanticColor.labelAlternative,
  );

  TextStyle get _mainValueStyle => AppTextStyles.display1.bold.copyWith(
    color: context.semanticColor.labelStrong,
  );

  TextStyle get _errorStyle => AppTextStyles.body2.readingMedium.copyWith(
    color: context.semanticColor.labelAlternative,
  );

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final WorkoutStatistics statistics = await _getWorkoutStatisticsUseCase
          .execute(periodType: _selectedPeriodType);

      setState(() {
        _currentStatistics = statistics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildPeriodSelector(),
        const SizedBox(height: _UIConstants.defaultSpacing),
        _buildPeriodTitle(),
        const SizedBox(height: _UIConstants.defaultSpacing),
        _buildDataTypeSelector(),
        const SizedBox(height: _UIConstants.defaultSpacing),
        _buildDataTypeLabel(),
        _buildContentByState(),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedControl<StatisticPeriodType>(
      tabs: _periodTabs,
      selectedTab: _selectedPeriodType,
      onTabSelected: (StatisticPeriodType type) {
        setState(() {
          _selectedPeriodType = type;
        });
        _loadStatistics();
      },
      labelExtractor: (StatisticPeriodType type) => type.label,
    );
  }

  Widget _buildPeriodTitle() {
    //TODO : 클릭 시 기간 변경 옵션 띄우기
    return Text(_getPeriodDisplayText(), style: _titleStyle);
  }

  Widget _buildDataTypeSelector() {
    return SegmentedControl<StaticDataType>(
      tabs: _dataTypeTabs,
      selectedTab: _selectedDataType,
      onTabSelected: (StaticDataType type) {
        setState(() {
          _selectedDataType = type;
        });
      },
      labelExtractor: (StaticDataType type) => type.label,
    );
  }

  Widget _buildDataTypeLabel() {
    return Text(_selectedDataType.label, style: _labelStyle);
  }

  Widget _buildContentByState() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_error != null) {
      return _buildErrorState();
    } else if (_currentStatistics != null) {
      return _buildDataContent();
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: _UIConstants.loadingPadding,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: _UIConstants.defaultSpacing,
      ),
      child: Center(
        child: Text('데이터를 불러올 수 없습니다: $_error', style: _errorStyle),
      ),
    );
  }

  Widget _buildDataContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(_getMainValue(), style: _mainValueStyle),
        const SizedBox(height: _UIConstants.defaultSpacing),
        Row(children: _buildBottomInfoItems()),
        const SizedBox(height: _UIConstants.largeSpacing),
        _buildChart(),
      ],
    );
  }

  Widget _buildChart() {
    final WorkoutStatisticsChartData? chartData = _currentStatistics?.chartData;
    final List<WorkoutStatisticsChartPoint> chartPoints =
        chartData != null
            ? _getChartPointsFromData(chartData)
            : <WorkoutStatisticsChartPoint>[];

    if (chartData == null ||
        chartPoints.isEmpty ||
        chartPoints.every(
          (WorkoutStatisticsChartPoint point) => point.value == 0,
        )) {
      return _buildEmptyChart();
    }

    return SizedBox(
      height: _UIConstants.chartHeight,
      child: BarChart(_buildChartData(chartPoints)),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: _UIConstants.chartHeight,
      decoration: BoxDecoration(
        border: Border.all(color: context.semanticColor.lineNormalNormal),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '데이터가 없습니다',
          style: AppTextStyles.body2.readingMedium.copyWith(
            color: context.semanticColor.labelAlternative,
          ),
        ),
      ),
    );
  }

  BarChartData _buildChartData(List<WorkoutStatisticsChartPoint> chartPoints) {
    return BarChartData(
      barGroups: _buildBarGroups(chartPoints),
      titlesData: _buildTitlesData(chartPoints),
      gridData: _buildGridData(chartPoints),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: _calculateChartMaxY(chartPoints),
      barTouchData: _buildTouchData(chartPoints),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<WorkoutStatisticsChartPoint> chartPoints,
  ) {
    return chartPoints.asMap().entries.map((
      MapEntry<int, WorkoutStatisticsChartPoint> entry,
    ) {
      return BarChartGroupData(
        x: entry.key,
        barRods: <BarChartRodData>[
          BarChartRodData(
            toY: entry.value.value,
            color: _barColor,
            width: _UIConstants.barWidth,
            borderRadius: const BorderRadius.vertical(),
          ),
        ],
      );
    }).toList();
  }

  FlTitlesData _buildTitlesData(List<WorkoutStatisticsChartPoint> chartPoints) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _calculateYAxisReservedSize(chartPoints),
          getTitlesWidget: (double value, TitleMeta meta) {
            final double interval = _getYAxisInterval(chartPoints);
            if (value % interval != 0) {
              return const Text('');
            }
            return Text(_formatYAxisLabel(value), style: _chartLabelStyle);
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (double value, TitleMeta meta) {
            final int index = value.toInt();
            if (index >= 0 && index < chartPoints.length) {
              return Text(chartPoints[index].label, style: _chartLabelStyle);
            }
            return const Text('');
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  FlGridData _buildGridData(List<WorkoutStatisticsChartPoint> chartPoints) {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: false,
      horizontalInterval: _getYAxisInterval(chartPoints),
      getDrawingHorizontalLine:
          (double value) => FlLine(
            color: _gridLineColor,
            strokeWidth: _UIConstants.gridLineWidth,
          ),
    );
  }

  BarTouchData _buildTouchData(List<WorkoutStatisticsChartPoint> chartPoints) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipItem: (
          BarChartGroupData group,
          int groupIndex,
          BarChartRodData rod,
          int rodIndex,
        ) {
          return BarTooltipItem(
            '${chartPoints[group.x].label}\n${_formatYAxisLabel(rod.toY)}',
            AppTextStyles.caption2.regular.copyWith(color: _tooltipTextColor),
          );
        },
      ),
    );
  }

  List<WorkoutStatisticsChartPoint> _getChartPointsFromData(
    WorkoutStatisticsChartData chartData,
  ) {
    switch (_selectedDataType) {
      case StaticDataType.distance:
        return chartData.distancePoints;
      case StaticDataType.elevation:
        return chartData.elevationPoints;
      case StaticDataType.duration:
        return chartData.durationPoints;
    }
  }

  String _formatYAxisLabel(double value) {
    switch (_selectedDataType) {
      case StaticDataType.distance:
        return '${value.toStringAsFixed(0)} km';
      case StaticDataType.elevation:
        return '${value.toStringAsFixed(0)} m';
      case StaticDataType.duration:
        return '${value.toStringAsFixed(0)} 분';
    }
  }

  double _getMaxYValue(List<WorkoutStatisticsChartPoint> points) {
    if (points.isEmpty) return 100;
    return points
        .map((WorkoutStatisticsChartPoint p) => p.value)
        .reduce((double a, double b) => a > b ? a : b);
  }

  double _getYAxisInterval(List<WorkoutStatisticsChartPoint> points) {
    final double maxValue = _getMaxYValue(points);
    if (maxValue <= 10) return 2;
    if (maxValue <= 50) return 10;
    if (maxValue <= 100) return 20;
    if (maxValue <= 500) return 100;
    return (maxValue / 5).roundToDouble();
  }

  double _calculateYAxisReservedSize(List<WorkoutStatisticsChartPoint> points) {
    final double maxValue = _getMaxYValue(points);
    final String formattedMaxValue = _formatYAxisLabel(maxValue);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: formattedMaxValue,
        style: AppTextStyles.caption2.regular.copyWith(
          color: context.semanticColor.labelAlternative,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    return textPainter.size.width + _UIConstants.reservedSizePadding;
  }

  double _calculateChartMaxY(List<WorkoutStatisticsChartPoint> points) {
    final double maxValue = _getMaxYValue(points);
    final double interval = _getYAxisInterval(points);

    // interval 단위로 올림 후 약간의 여유 공간 추가하여 상단 grid line 표시
    return ((maxValue / interval).ceil()) * interval +
        (interval * _UIConstants.topPaddingRatio);
  }

  //TODO : api 연동 후 변경 필요
  String _getPeriodDisplayText() {
    if (_currentStatistics != null) {
      return _currentStatistics!.period.displayTitle;
    }

    switch (_selectedPeriodType) {
      case StatisticPeriodType.week:
        return '25년 7월 3주';
      case StatisticPeriodType.month:
        return '25년 7월';
      case StatisticPeriodType.year:
        return '2025년';
      case StatisticPeriodType.all:
        return '전체';
    }
  }

  String _getMainValue() {
    if (_currentStatistics == null) return '--';

    final WorkoutStatisticsSummary summary = _currentStatistics!.summary;

    switch (_selectedDataType) {
      case StaticDataType.distance:
        return WorkoutFormatter.toKmText(
          summary.totalDistance * 1000,
        ); // km → m 변환
      case StaticDataType.elevation:
        return WorkoutFormatter.toAltitudeText(
          summary.totalElevationGain.toDouble(),
        );
      case StaticDataType.duration:
        return WorkoutFormatter.toDurationText(summary.totalDuration);
    }
  }

  List<Widget> _buildBottomInfoItems() {
    switch (_selectedDataType) {
      case StaticDataType.distance:
        return <Widget>[
          _buildRidingCountItem(),
          _buildWorkoutTimeItem(),
          _buildElevationItem(),
        ];
      case StaticDataType.elevation:
        return <Widget>[
          _buildRidingCountItem(),
          _buildWorkoutTimeItem(),
          _buildDistanceItem(),
        ];
      case StaticDataType.duration:
        return <Widget>[
          _buildRidingCountItem(),
          _buildDistanceItem(),
          _buildElevationItem(),
        ];
    }
  }

  Widget _buildRidingCountItem() {
    final int count = _currentStatistics?.summary.totalActivityCount ?? 0;
    return Expanded(
      child: InfoItem(
        label: '라이딩',
        value: '$count',
        alignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget _buildWorkoutTimeItem() {
    final Duration? duration = _currentStatistics?.summary.totalDuration;
    return Expanded(
      child: InfoItem(
        label: '운동 시간',
        value: WorkoutFormatter.toDurationText(duration),
        alignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget _buildDistanceItem() {
    final double? distance = _currentStatistics?.summary.totalDistance;
    return Expanded(
      child: InfoItem(
        label: '거리',
        value: WorkoutFormatter.toKmText(
          distance != null ? distance * 1000 : null,
        ), // km → m 변환
        alignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget _buildElevationItem() {
    final int? elevation = _currentStatistics?.summary.totalElevationGain;
    return Expanded(
      child: InfoItem(
        label: '상승 고도',
        value: WorkoutFormatter.toAltitudeText(elevation?.toDouble()),
        alignment: CrossAxisAlignment.start,
      ),
    );
  }
}
