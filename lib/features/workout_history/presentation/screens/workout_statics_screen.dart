import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/info/info_item.dart';
import 'package:ridingmate/shared/design_system/widgets/segmented_control/segmented_control.dart';

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

  final double distance; // km
  final double elevation; // m
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
          distance: 3.14,
          elevation: 100,
          duration: Duration(hours: 1, minutes: 13, seconds: 13),
          ridingCount: 1,
          workoutTime: Duration(hours: 1, minutes: 13, seconds: 13),
        ),
        StatisticPeriodType.month: const _StatisticData(
          distance: 45.8, // 가장 큰 거리
          elevation: 580,
          duration: Duration(hours: 15, minutes: 30),
          ridingCount: 8,
          workoutTime: Duration(hours: 12, minutes: 45),
        ),
        StatisticPeriodType.year: const _StatisticData(
          distance: 285.6,
          elevation: 2850, // 가장 큰 상승고도
          duration: Duration(hours: 85, minutes: 20),
          ridingCount: 42,
          workoutTime: Duration(hours: 78, minutes: 15),
        ),
        StatisticPeriodType.all: const _StatisticData(
          distance: 420.3,
          elevation: 3200,
          duration: Duration(hours: 125, minutes: 45), // 가장 긴 시간
          ridingCount: 65,
          workoutTime: Duration(hours: 115, minutes: 30),
        ),
      };

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final _StatisticData currentData = _mockData[_selectedPeriodType]!;

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
        //TODO : 클릭 시 월 변경 옵션 띄우기
        Text(
          '25년 7월',
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
          '주간 라이딩 거리',
          style: AppTextStyles.label1.normalBold.copyWith(
            color: colors.labelAlternative,
          ),
        ),
        Text(
          '3.14 km',
          style: AppTextStyles.display1.bold.copyWith(
            color: colors.labelStrong,
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          children: <Widget>[
            Expanded(
              child: InfoItem(
                label: '라이딩',
                value: '1',
                alignment: CrossAxisAlignment.start,
              ),
            ),
            Expanded(
              child: InfoItem(
                label: '운동 시간',
                value: '1:13:13',
                alignment: CrossAxisAlignment.start,
              ),
            ),
            Expanded(
              child: InfoItem(
                label: '상승 고도',
                value: '100m',
                alignment: CrossAxisAlignment.start,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
