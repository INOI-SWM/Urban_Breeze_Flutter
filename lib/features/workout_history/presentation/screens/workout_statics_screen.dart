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
import '../widgets/period_selector_dialog.dart';

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

  // 기간 선택을 위한 상태 변수
  PeriodSelection _periodSelection = PeriodSelection(
    year: DateTime.now().year,
    month: DateTime.now().month,
    week: _getCurrentWeekOfMonth(),
  );

  static int _getCurrentWeekOfMonth() {
    final DateTime now = DateTime.now();
    final DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday;
    final int day = now.day;
    return ((day + firstWeekday - 2) ~/ 7) + 1;
  }

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
    if (_selectedPeriodType == StatisticPeriodType.all) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text(_getPeriodDisplayText(), style: _titleStyle),
      );
    }

    return InkWell(
      onTap: _showPeriodSelector,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(_getPeriodDisplayText(), style: _titleStyle),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
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
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return BarChart(_buildChartData(chartPoints, constraints.maxWidth));
        },
      ),
    );
  }

  Widget _buildEmptyChart() {
    return SizedBox(
      height: _UIConstants.chartHeight,
      child: Container(
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
      ),
    );
  }

  BarChartData _buildChartData(
    List<WorkoutStatisticsChartPoint> chartPoints,
    double availableWidth,
  ) {
    final double barWidth = _calculateDynamicBarWidth(
      chartPoints.length,
      availableWidth,
    );

    return BarChartData(
      barGroups: _buildBarGroups(chartPoints, barWidth),
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
    double barWidth,
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
            width: barWidth,
            borderRadius: const BorderRadius.vertical(),
          ),
        ],
      );
    }).toList();
  }

  double _calculateDynamicBarWidth(int dataCount, double availableWidth) {
    if (_currentStatistics?.chartData == null || dataCount <= 0) {
      return _UIConstants.barWidth;
    }

    final double yAxisReservedSize = _calculateYAxisReservedSize(
      _getChartPointsFromData(_currentStatistics!.chartData),
    );

    const double horizontalPadding = 40;
    final double chartGraphWidth =
        availableWidth - yAxisReservedSize - horizontalPadding;

    if (chartGraphWidth <= 0) {
      return _UIConstants.barWidth;
    }

    final double calculatedWidth = chartGraphWidth / dataCount;

    const double minWidth = 4.0;
    const double maxWidth = 30.0;

    return calculatedWidth.clamp(minWidth, maxWidth);
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
              // 기간 타입에 따라 라벨 표시 간격 조정
              if (_shouldShowXAxisLabel(index, chartPoints.length)) {
                return Text(chartPoints[index].label, style: _chartLabelStyle);
              }
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
    if (maxValue <= 1000) return 200;
    if (maxValue <= 5000) return 1000;
    if (maxValue <= 10000) return 2000;
    if (maxValue <= 50000) return 10000;

    // 매우 큰 값들은 적절한 10의 배수로 설정
    final double baseInterval = (maxValue / 5).roundToDouble();
    if (baseInterval >= 10000) {
      return (baseInterval / 10000).round() * 10000.0;
    } else if (baseInterval >= 1000) {
      return (baseInterval / 1000).round() * 1000.0;
    } else if (baseInterval >= 100) {
      return (baseInterval / 100).round() * 100.0;
    }
    return baseInterval;
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

  DateTime _getStartOfWeek(int year, int month, int week) {
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int firstWeekday = firstDayOfMonth.weekday;
    final int daysToAdd = (week - 1) * 7 - (firstWeekday - 1);
    return firstDayOfMonth.add(Duration(days: daysToAdd));
  }

  DateTime _getEndOfWeek(int year, int month, int week) {
    final DateTime startOfWeek = _getStartOfWeek(year, month, week);
    return startOfWeek.add(const Duration(days: 6));
  }

  String _formatWeekRange(int year, int month, int week) {
    final DateTime startDate = _getStartOfWeek(year, month, week);
    final DateTime endDate = _getEndOfWeek(year, month, week);

    final int startMonth = startDate.month;
    final int startDay = startDate.day;
    final int endMonth = endDate.month;
    final int endDay = endDate.day;

    if (startMonth == endMonth) {
      return '($startMonth/$startDay - $endMonth/$endDay)';
    } else {
      return '($startMonth/$startDay - $endMonth/$endDay)';
    }
  }

  //TODO : api 연동 후 변경 필요
  String _getPeriodDisplayText() {
    switch (_selectedPeriodType) {
      case StatisticPeriodType.week:
        final String weekRange = _formatWeekRange(
          _periodSelection.year,
          _periodSelection.month,
          _periodSelection.week,
        );
        return '${_periodSelection.year}년 ${_periodSelection.month}월 ${_periodSelection.week}주 $weekRange';
      case StatisticPeriodType.month:
        return '${_periodSelection.year}년 ${_periodSelection.month}월';
      case StatisticPeriodType.year:
        return '${_periodSelection.year}년';
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

  bool _shouldShowXAxisLabel(int index, int totalPoints) {
    switch (_selectedPeriodType) {
      case StatisticPeriodType.week:
        return true;
      case StatisticPeriodType.month:
        // 월간 데이터: 1일, 5일, 10일, 15일, 20일, 25일, 30일만 표시
        return index == 0 || (index + 1) % 5 == 0;
      case StatisticPeriodType.year:
        return true;
      case StatisticPeriodType.all:
        return true;
    }
  }

  void _showPeriodSelector() {
    PeriodSelectorDialog.show(
      context,
      periodType: _selectedPeriodType,
      initialSelection: _periodSelection,
      onPeriodChanged: (PeriodSelection newSelection) {
        setState(() {
          _periodSelection = newSelection;
        });
        _loadStatistics();
      },
      startDate: DateTime(2020, 7, 22),
    );
  }
}
