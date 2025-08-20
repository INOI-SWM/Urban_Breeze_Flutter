import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/workout_list_screen.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/workout_statics_screen.dart';
import 'package:urban_breeze/navigation/navigation_providers.dart';
import 'package:urban_breeze/navigation/page_with_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/tab_bar/custom_tab_bar.dart';

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

class WorkoutHistoryPage extends ConsumerStatefulWidget
    implements PageWithAppBar {
  const WorkoutHistoryPage({super.key});

  @override
  ConsumerState<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();

  @override
  PreferredSizeWidget getAppBar(BuildContext context) {
    return const CustomAppBar(title: '기록');
  }
}

class _WorkoutHistoryPageState extends ConsumerState<WorkoutHistoryPage> {
  WorkoutHistoryTab _selectedTab = WorkoutHistoryTab.statistics;

  static const List<WorkoutHistoryTab> _tabs = <WorkoutHistoryTab>[
    WorkoutHistoryTab.statistics,
    WorkoutHistoryTab.ridingHistory,
  ];

  @override
  Widget build(BuildContext context) {
    // 전역 상태의 선택된 탭을 반영 (홈에서 더보기 클릭 시 업데이트됨)
    final WorkoutHistoryTab desiredTab = ref.watch(workoutHistoryTabProvider);
    if (_selectedTab != desiredTab) {
      _selectedTab = desiredTab;
    }
    return Column(
      children: <Widget>[
        CustomTabBar<WorkoutHistoryTab>(
          tabs: _tabs,
          selectedTab: _selectedTab,
          onTabSelected: (WorkoutHistoryTab tab) {
            setState(() {
              _selectedTab = tab;
            });
            ref.read(workoutHistoryTabProvider.notifier).state = tab;
          },
          labelExtractor: (WorkoutHistoryTab tab) => tab.label,
        ),
        Expanded(child: _buildContent()),
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
