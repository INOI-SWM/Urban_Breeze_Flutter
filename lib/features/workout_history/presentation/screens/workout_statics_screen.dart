import 'package:flutter/material.dart';
import 'package:ridingmate/shared/design_system/widgets/segmented_control/segmented_control.dart';

enum StatisticType {
  week,
  month,
  year,
  all;

  String get label {
    switch (this) {
      case StatisticType.week:
        return '주';
      case StatisticType.month:
        return '월';
      case StatisticType.year:
        return '년';
      case StatisticType.all:
        return '전체';
    }
  }
}

class WorkoutStaticsScreen extends StatefulWidget {
  const WorkoutStaticsScreen({super.key});

  @override
  State<WorkoutStaticsScreen> createState() => _WorkoutStaticsScreenState();
}

class _WorkoutStaticsScreenState extends State<WorkoutStaticsScreen> {
  StatisticType _selectedType = StatisticType.week;

  static const List<StatisticType> _tabs = <StatisticType>[
    StatisticType.week,
    StatisticType.month,
    StatisticType.year,
    StatisticType.all,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          SegmentedControl<StatisticType>(
            tabs: _tabs,
            selectedTab: _selectedType,
            onTabSelected: (StatisticType type) {
              setState(() {
                _selectedType = type;
              });
            },
            labelExtractor: (StatisticType type) => type.label,
          ),

          const SizedBox(height: 32),

          Expanded(child: _buildStatisticContent()),
        ],
      ),
    );
  }

  Widget _buildStatisticContent() {
    return Container();
  }
}
