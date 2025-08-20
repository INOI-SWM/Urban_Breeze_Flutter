import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/sync_apple_health_kit_data_use_case.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/sync_google_health_connect_data_use_case.dart';
import 'package:urban_breeze/features/workout_history/di/workout_statistics_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_record.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/sync_screen.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/workout_list_screen.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/workout_statics_screen.dart';
import 'package:urban_breeze/navigation/navigation_providers.dart';
import 'package:urban_breeze/navigation/page_with_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
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
    final _WorkoutHistoryPageState? state =
        context.findAncestorStateOfType<_WorkoutHistoryPageState>();

    return CustomAppBar(
      title: '기록',
      actions: <Widget>[
        CustomIconButton(
          onTap: () => state?._syncAllData(),
          icon: Icons.refresh,
        ),
        CustomIconButton(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const SyncScreen(),
              ),
            );
          },
          icon: Icons.settings,
        ),
      ],
    );
  }
}

class _WorkoutHistoryPageState extends ConsumerState<WorkoutHistoryPage> {
  WorkoutHistoryTab _selectedTab = WorkoutHistoryTab.statistics;
  bool _isSyncing = false;
  Function(List<WorkoutRecord>)? _updateWorkoutsCallback;

  static const List<WorkoutHistoryTab> _tabs = <WorkoutHistoryTab>[
    WorkoutHistoryTab.statistics,
    WorkoutHistoryTab.ridingHistory,
  ];

  // 모든 데이터 자동 동기화 메서드
  Future<void> _syncAllData() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    final List<WorkoutRecord> allWorkouts = <WorkoutRecord>[];
    int successCount = 0;
    int totalAttempts = 0;

    try {
      // Apple Health Kit 동기화 시도
      totalAttempts++;
      try {
        final SyncAppleHealthKitDataUseCase appleUseCase = ref.read(
          syncAppleHealthKitDataUseCaseProvider,
        );
        final List<WorkoutRecord> appleWorkouts = await appleUseCase
            .fetchBasicWorkoutData(
              startDate: DateTime.now().subtract(const Duration(days: 30)),
              endDate: DateTime.now(),
            );
        allWorkouts.addAll(appleWorkouts);
        successCount++;
      } catch (e) {
        // Apple Health Kit 동기화 실패 (권한 없거나 오류)
      }

      // Google Health Connect 동기화 시도
      totalAttempts++;
      try {
        final SyncGoogleHealthConnectDataUseCase googleUseCase = ref.read(
          syncGoogleHealthConnectDataUseCaseProvider,
        );
        final Map<WorkoutRecord, Map<String, dynamic>> completeData =
            await googleUseCase.syncCompleteWorkoutData(
              startDate: DateTime.now().subtract(const Duration(days: 1000)),
              endDate: DateTime.now(),
            );
        allWorkouts.addAll(completeData.keys.toList());
        successCount++;
      } catch (e) {
        // Google Health Connect 동기화 실패 (권한 없거나 오류)
      }

      setState(() {
        _isSyncing = false;
      });

      // 결과 메시지 표시 및 데이터 전달
      if (mounted) {
        String message;
        if (successCount == 0) {
          message = '동기화할 수 있는 데이터가 없습니다. 설정에서 권한을 확인해주세요.';
        } else if (successCount == totalAttempts) {
          message = '모든 데이터 동기화 완료! 총 ${allWorkouts.length}개의 운동 기록을 가져왔습니다.';
        } else {
          message = '일부 데이터 동기화 완료! 총 ${allWorkouts.length}개의 운동 기록을 가져왔습니다.';
        }

        // WorkoutListScreen에 데이터 전달
        if (allWorkouts.isNotEmpty) {
          _updateWorkoutsCallback?.call(allWorkouts);
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      setState(() {
        _isSyncing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('동기화 중 오류가 발생했습니다.')));
      }
    }
  }

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
        return WorkoutListScreen(
          onUpdateData: (Function(List<WorkoutRecord>) updateCallback) {
            _updateWorkoutsCallback = updateCallback;
          },
        );
    }
  }
}
