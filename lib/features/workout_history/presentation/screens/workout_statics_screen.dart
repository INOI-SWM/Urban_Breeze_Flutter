import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/chart/chart_axis_utils.dart';
import 'package:urban_breeze/shared/chart/chart_builders.dart';
import 'package:urban_breeze/shared/chart/chart_style_config.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_item.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/design_system/widgets/segmented_control/segmented_control.dart';
import 'package:urban_breeze/shared/utils/display_formatter.dart';
import 'package:urban_breeze/shared/utils/period_utils.dart';
import 'package:urban_breeze/shared/utils/workout_formatter.dart';

import '../../application/use_cases/get_workout_statistics_use_case.dart';
import '../../di/workout_history_providers.dart';
import '../../domain/entities/period_selection.dart';
import '../../domain/entities/workout_statistics.dart';
import '../../domain/enums/statistic_enums.dart';
import '../pages/workout_history_page.dart';
import '../widgets/period_selector_dialog.dart';

class _UIConstants {
  static const double defaultSpacing = 12.0;
  static const double largeSpacing = 30.0;
  static const double barWidth = 20.0;
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
    week: PeriodUtils.getWeekOfMonth(DateTime.now()),
  );

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
    // 화면 조회 이벤트
    AmplitudeAnalytics.logScreenView('workout_statistics_screen');

    _getWorkoutStatisticsUseCase = ref.read(
      getWorkoutStatisticsUseCaseProvider,
    );
    _loadStatistics();
  }

  TextStyle get _chartLabelStyle =>
      ChartStyleConfig.getAxisLabelStyle(context.semanticColor);

  Color get _barColor => context.semanticColor.primaryNormal;

  Color get _tooltipTextColor =>
      ChartStyleConfig.getTooltipTextColor(context.semanticColor);

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
          .execute(
            periodType: _selectedPeriodType,
            periodSelection: _periodSelection,
          );

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
    // 동기화 완료 이벤트 감지
    ref.listen(syncCompleteProvider, (int? previous, int next) {
      if (previous != null && next > previous) {
        // 새로고침 시작 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('새로운 데이터를 불러오는 중...'),
            duration: Duration(seconds: 2),
          ),
        );
        _loadStatistics();
      }
    });

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildPeriodSelector(),
          const SizedBox(height: _UIConstants.defaultSpacing),
          _buildPeriodTitle(),
          const SizedBox(height: _UIConstants.defaultSpacing),
          _buildDataTypeSelector(),
          const SizedBox(height: _UIConstants.defaultSpacing),
          _buildDataTypeLabel(),
          Expanded(child: _buildContentByState()),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return SegmentedControl<StatisticPeriodType>(
      tabs: _periodTabs,
      selectedTab: _selectedPeriodType,
      onTabSelected: (StatisticPeriodType type) {
        // 기간 변경 이벤트
        AmplitudeAnalytics.logEvent(
          'workout_statistics_period_changed',
          properties: <String, dynamic>{
            'period_type': type.name,
            'period_label': type.label,
            'previous_period_type': _selectedPeriodType.name,
          },
        );

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
        // 데이터 타입 변경 이벤트
        AmplitudeAnalytics.logEvent(
          'workout_statistics_data_type_changed',
          properties: <String, dynamic>{
            'data_type': type.name,
            'data_type_label': type.label,
            'previous_data_type': _selectedDataType.name,
          },
        );

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
      if (_currentStatistics!.oldestActivityDate == null) {
        return _buildEmptyState();
      }
      return _buildDataContent();
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: _UIConstants.loadingPadding,
      child: Center(child: AppLoadingIndicator()),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.directions_bike,
            size: 56,
            color: context.semanticColor.labelAlternative,
          ),
          const SizedBox(height: 16),
          Text(
            '운동기록이 없습니다',
            style: AppTextStyles.title3.bold.copyWith(
              color: context.semanticColor.labelStrong,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '서비스를 연동해 데이터를 동기화해보세요',
            style: AppTextStyles.body2.readingMedium.copyWith(
              color: context.semanticColor.labelAlternative,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
        Expanded(child: _buildChart()),
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

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return BarChart(_buildChartData(chartPoints, constraints.maxWidth));
      },
    );
  }

  Widget _buildEmptyChart() {
    return Container(
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

  BarChartData _buildChartData(
    List<WorkoutStatisticsChartPoint> chartPoints,
    double availableWidth,
  ) {
    final double barWidth = _calculateDynamicBarWidth(
      chartPoints.length,
      availableWidth,
    );

    final double maxValue = ChartAxisUtils.getMaxValue(
      chartPoints,
      (WorkoutStatisticsChartPoint point) => point.value,
    );
    final double interval = ChartAxisUtils.calculateInterval(maxValue);

    return BarChartData(
      barGroups: _buildBarGroups(chartPoints, barWidth),
      titlesData: _buildTitlesData(chartPoints, interval),
      gridData: ChartBuilders.buildGridData(
        colors: context.semanticColor,
        interval: interval,
      ),
      borderData: ChartBuilders.buildBorderData(),
      minY: 0,
      maxY: ChartAxisUtils.calculateChartMaxY(
        ChartAxisUtils.getMaxValue(
          chartPoints,
          (WorkoutStatisticsChartPoint point) => point.value,
        ),
        interval,
      ),
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

  FlTitlesData _buildTitlesData(
    List<WorkoutStatisticsChartPoint> chartPoints,
    double interval,
  ) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _calculateYAxisReservedSize(chartPoints),
          getTitlesWidget: (double value, TitleMeta meta) {
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
                final String formattedLabel = _formatXAxisLabel(
                  chartPoints[index].label,
                );
                return Text(formattedLabel, style: _chartLabelStyle);
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
          final String formattedLabel = _formatTooltipLabel(
            chartPoints[group.x].label,
          );
          return BarTooltipItem(
            '$formattedLabel\n${_formatYAxisLabel(rod.toY)}',
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

  String _formatTooltipLabel(String label) {
    switch (_selectedPeriodType) {
      case StatisticPeriodType.week:
        // 주간: "29" -> "6월 29일"
        final int day = int.tryParse(label) ?? 0;
        if (day > 0) {
          return '${_periodSelection.month}월 $day일';
        }
        return label;

      case StatisticPeriodType.month:
        // 월간: "15" -> "9월 15일"
        final int day = int.tryParse(label) ?? 0;
        if (day > 0) {
          return '${_periodSelection.month}월 $day일';
        }
        return label;

      case StatisticPeriodType.year:
        // 연간: "3" -> "3월"
        final int month = int.tryParse(label) ?? 0;
        if (month > 0) {
          return '$month월';
        }
        return label;

      case StatisticPeriodType.all:
        // 전체: 원본 라벨 그대로 사용 (서버에서 적절한 형식으로 올 것으로 예상)
        return label;
    }
  }

  String _formatXAxisLabel(String label) {
    // X축에서는 간단하게 숫자만 표시
    return label;
  }

  double _calculateYAxisReservedSize(List<WorkoutStatisticsChartPoint> points) {
    final double maxValue = ChartAxisUtils.getMaxValue(
      points,
      (WorkoutStatisticsChartPoint point) => point.value,
    );
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

    return textPainter.size.width + ChartStyleConfig.reservedSizePadding;
  }

  String _getPeriodDisplayText() {
    switch (_selectedPeriodType) {
      case StatisticPeriodType.week:
        final String weekRange = PeriodUtils.formatWeekRange(
          _periodSelection.year,
          _periodSelection.month,
          _periodSelection.week,
        );
        return '${_periodSelection.year % 100}년 ${_periodSelection.month}월 ${_periodSelection.week}주 $weekRange';
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
        return DisplayFormatter.formatElevationGain(
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
    final double? elevation = _currentStatistics?.summary.totalElevationGain;
    return Expanded(
      child: InfoItem(
        label: '상승 고도',
        value: DisplayFormatter.formatElevationGain(elevation?.toDouble()),
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
    // 기간 선택 다이얼로그 열기 이벤트
    AmplitudeAnalytics.logEvent(
      'workout_statistics_period_selector_opened',
      properties: <String, dynamic>{
        'current_period_type': _selectedPeriodType.name,
        'current_period_selection': <String, int>{
          'year': _periodSelection.year,
          'month': _periodSelection.month,
          'week': _periodSelection.week,
        },
      },
    );

    PeriodSelectorDialog.show(
      context,
      periodType: _selectedPeriodType,
      initialSelection: _periodSelection,
      onPeriodChanged: (PeriodSelection newSelection) {
        // 기간 선택 변경 이벤트
        AmplitudeAnalytics.logEvent(
          'workout_statistics_period_selection_changed',
          properties: <String, dynamic>{
            'period_type': _selectedPeriodType.name,
            'previous_selection': <String, int>{
              'year': _periodSelection.year,
              'month': _periodSelection.month,
              'week': _periodSelection.week,
            },
            'new_selection': <String, int>{
              'year': newSelection.year,
              'month': newSelection.month,
              'week': newSelection.week,
            },
          },
        );

        setState(() {
          _periodSelection = newSelection;
        });
        _loadStatistics();
      },
      startDate:
          _currentStatistics?.oldestActivityDate ?? DateTime(2025, 10, 1),
    );
  }
}
