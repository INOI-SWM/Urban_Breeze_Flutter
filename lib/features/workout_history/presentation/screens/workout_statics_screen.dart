import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/info/info_item.dart';
import 'package:ridingmate/shared/design_system/widgets/segmented_control/segmented_control.dart';
import 'package:ridingmate/shared/utils/workout_formatter.dart';

import '../../application/use_cases/get_workout_statistics_use_case.dart';
import '../../di/workout_statistics_providers.dart';
import '../../domain/entities/workout_statistics.dart';

enum StatisticPeriodType {
  week,
  month,
  year,
  all;

  String get label {
    switch (this) {
      case StatisticPeriodType.week:
        return '주';
      case StatisticPeriodType.month:
        return '월';
      case StatisticPeriodType.year:
        return '년';
      case StatisticPeriodType.all:
        return '전체';
    }
  }

  String get apiValue {
    switch (this) {
      case StatisticPeriodType.week:
        return 'week';
      case StatisticPeriodType.month:
        return 'month';
      case StatisticPeriodType.year:
        return 'year';
      case StatisticPeriodType.all:
        return 'all';
    }
  }
}

enum StaticDataType {
  distance,
  elevation,
  duration;

  String get label {
    switch (this) {
      case StaticDataType.distance:
        return '거리';
      case StaticDataType.elevation:
        return '상승 고도';
      case StaticDataType.duration:
        return '시간';
    }
  }
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

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final WorkoutStatistics statistics = await _getWorkoutStatisticsUseCase
          .execute(periodType: _selectedPeriodType.apiValue);

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
    final SemanticColors colors = context.semanticColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SegmentedControl<StatisticPeriodType>(
          tabs: _periodTabs,
          selectedTab: _selectedPeriodType,
          onTabSelected: (StatisticPeriodType type) {
            setState(() {
              _selectedPeriodType = type;
            });
            _loadStatistics();
          },
          labelExtractor: (StatisticPeriodType type) => type.label,
        ),

        const SizedBox(height: 20),
        //TODO : 클릭 시 기간 변경 옵션 띄우기
        Text(
          _getPeriodDisplayText(),
          style: AppTextStyles.title3.bold.copyWith(color: colors.labelStrong),
        ),
        const SizedBox(height: 20),
        SegmentedControl<StaticDataType>(
          tabs: _dataTypeTabs,
          selectedTab: _selectedDataType,
          onTabSelected: (StaticDataType type) {
            setState(() {
              _selectedDataType = type;
            });
          },
          labelExtractor: (StaticDataType type) => type.label,
        ),
        const SizedBox(height: 20),
        Text(
          _selectedDataType.label,
          style: AppTextStyles.label1.normalBold.copyWith(
            color: colors.labelAlternative,
          ),
        ),

        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                '데이터를 불러올 수 없습니다: $_error',
                style: AppTextStyles.body2.readingMedium.copyWith(
                  color: colors.labelAlternative,
                ),
              ),
            ),
          )
        else if (_currentStatistics != null) ...<Widget>[
          Text(
            _getMainValue(),
            style: AppTextStyles.display1.bold.copyWith(
              color: colors.labelStrong,
            ),
          ),
          const SizedBox(height: 20),
          Row(children: _buildBottomInfoItems()),
        ],
      ],
    );
  }

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
        value:
            duration != null ? WorkoutFormatter.toDurationText(duration) : '--',
        alignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget _buildDistanceItem() {
    final double? distance = _currentStatistics?.summary.totalDistance;
    return Expanded(
      child: InfoItem(
        label: '거리',
        value:
            distance != null
                ? WorkoutFormatter.toKmText(distance * 1000) // km → m 변환
                : '--',
        alignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget _buildElevationItem() {
    final int? elevation = _currentStatistics?.summary.totalElevationGain;
    return Expanded(
      child: InfoItem(
        label: '상승 고도',
        value:
            elevation != null
                ? WorkoutFormatter.toAltitudeText(elevation.toDouble())
                : '--',
        alignment: CrossAxisAlignment.start,
      ),
    );
  }
}
