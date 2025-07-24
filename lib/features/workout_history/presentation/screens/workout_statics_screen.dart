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
