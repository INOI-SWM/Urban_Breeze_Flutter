import 'package:flutter/material.dart';
import 'package:ridingmate/features/workout_history/presentation/screens/workout_list_screen.dart';
import 'package:ridingmate/features/workout_history/presentation/screens/workout_statics_screen.dart';
import 'package:ridingmate/navigation/page_with_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/tab_bar/custom_tab_bar.dart';

enum WorkoutHistoryTab {
  statistics,
  ridingHistory;

  String get label {
    switch (this) {
      case WorkoutHistoryTab.statistics:
        return '통계';
      case WorkoutHistoryTab.ridingHistory:
        return '라이딩 기록';
    }
  }
}

class WorkoutHistoryPage extends StatefulWidget implements PageWithAppBar {
  const WorkoutHistoryPage({super.key});

  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();

  @override
  PreferredSizeWidget getAppBar(BuildContext context) {
    return const CustomAppBar(title: '기록');
  }
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  WorkoutHistoryTab _selectedTab = WorkoutHistoryTab.statistics;

  static const List<WorkoutHistoryTab> _tabs = <WorkoutHistoryTab>[
    WorkoutHistoryTab.statistics,
    WorkoutHistoryTab.ridingHistory,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CustomTabBar<WorkoutHistoryTab>(
          tabs: _tabs,
          selectedTab: _selectedTab,
          onTabSelected: (WorkoutHistoryTab tab) {
            setState(() {
              _selectedTab = tab;
            });
          },
          labelExtractor: (WorkoutHistoryTab tab) => tab.label,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case WorkoutHistoryTab.statistics:
        return const WorkoutStaticsScreen();
      case WorkoutHistoryTab.ridingHistory:
        return const WorkoutListScreen();
    }
  }
}
