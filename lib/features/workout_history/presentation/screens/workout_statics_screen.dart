import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/info/info_item.dart';
import 'package:ridingmate/shared/design_system/widgets/segmented_control/segmented_control.dart';
import 'package:ridingmate/shared/utils/workout_formatter.dart';

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

// TODO: 추후 실제 API 데이터로 교체
class _StatisticData {
  const _StatisticData({
    required this.distance,
    required this.elevation,
    required this.duration,
    required this.ridingCount,
    required this.workoutTime,
  });

  final int distance; // 미터 단위
  final int elevation; // 미터 단위
  final Duration duration; // 전체 시간
  final int ridingCount; // 라이딩 횟수
  final Duration workoutTime; // 실제 운동 시간
}

class WorkoutStaticsScreen extends StatefulWidget {
  const WorkoutStaticsScreen({super.key});

  @override
  State<WorkoutStaticsScreen> createState() => _WorkoutStaticsScreenState();
}

class _WorkoutStaticsScreenState extends State<WorkoutStaticsScreen> {
  StatisticPeriodType _selectedPeriodType = StatisticPeriodType.week;
  StaticDataType _selectedDataType = StaticDataType.distance;

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

  // TODO: 추후 실제 API 데이터로 교체
  final Map<StatisticPeriodType, _StatisticData> _mockData =
      <StatisticPeriodType, _StatisticData>{
        StatisticPeriodType.week: const _StatisticData(
          distance: 15200,
          elevation: 120,
          duration: Duration(hours: 2, minutes: 15, seconds: 30),
          ridingCount: 3,
          workoutTime: Duration(hours: 2, minutes: 10, seconds: 0),
        ),
        StatisticPeriodType.month: const _StatisticData(
          distance: 125800,
          elevation: 850,
          duration: Duration(hours: 18, minutes: 45),
          ridingCount: 12,
          workoutTime: Duration(hours: 16, minutes: 30),
        ),
        StatisticPeriodType.year: const _StatisticData(
          distance: 89300, // 미터 단위로 변경 (89.3km)
          elevation: 1850,
          duration: Duration(hours: 45, minutes: 20),
          ridingCount: 28,
          workoutTime: Duration(hours: 42, minutes: 15),
        ),
        StatisticPeriodType.all: const _StatisticData(
          distance: 95700, // 미터 단위로 변경 (95.7km)
          elevation: 1200,
          duration: Duration(hours: 85, minutes: 30),
          ridingCount: 48,
          workoutTime: Duration(hours: 78, minutes: 45),
        ),
      };

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
        Text(
          _getMainValue(),
          style: AppTextStyles.display1.bold.copyWith(
            color: colors.labelStrong,
          ),
        ),
        const SizedBox(height: 20),
        Row(children: _buildBottomInfoItems()),
      ],
    );
  }

  /// 선택된 기간에 따른 표시 텍스트
  String _getPeriodDisplayText() {
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
    final _StatisticData currentData = _mockData[_selectedPeriodType]!;

    switch (_selectedDataType) {
      case StaticDataType.distance:
        return WorkoutFormatter.toKmText(currentData.distance.toDouble());
      case StaticDataType.elevation:
        return WorkoutFormatter.toAltitudeText(
          currentData.elevation.toDouble(),
        );
      case StaticDataType.duration:
        return WorkoutFormatter.toDurationText(currentData.duration);
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

  /// 라이딩 횟수 항목
  Widget _buildRidingCountItem() {
    final _StatisticData currentData = _mockData[_selectedPeriodType]!;
    return Expanded(
      child: InfoItem(
        label: '라이딩',
        value: '${currentData.ridingCount}',
        alignment: CrossAxisAlignment.start,
      ),
    );
  }

  /// 운동 시간 항목
  Widget _buildWorkoutTimeItem() {
    final _StatisticData currentData = _mockData[_selectedPeriodType]!;
    return Expanded(
      child: InfoItem(
        label: '운동 시간',
        value: WorkoutFormatter.toDurationText(currentData.workoutTime),
        alignment: CrossAxisAlignment.start,
      ),
    );
  }

  /// 거리 항목
  Widget _buildDistanceItem() {
    final _StatisticData currentData = _mockData[_selectedPeriodType]!;
    return Expanded(
      child: InfoItem(
        label: '거리',
        value: WorkoutFormatter.toKmText(currentData.distance.toDouble()),
        alignment: CrossAxisAlignment.start,
      ),
    );
  }

  /// 상승 고도 항목
  Widget _buildElevationItem() {
    final _StatisticData currentData = _mockData[_selectedPeriodType]!;
    return Expanded(
      child: InfoItem(
        label: '상승 고도',
        value: WorkoutFormatter.toAltitudeText(
          currentData.elevation.toDouble(),
        ),
        alignment: CrossAxisAlignment.start,
      ),
    );
  }
}
