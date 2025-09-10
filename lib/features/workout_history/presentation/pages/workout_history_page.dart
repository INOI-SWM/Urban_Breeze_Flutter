import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/facades/workout_sync_facade.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_record.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/sync_screen.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/workout_list_screen.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/workout_statics_screen.dart';
import 'package:urban_breeze/navigation/navigation_providers.dart';
import 'package:urban_breeze/navigation/page_with_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/tab_bar/custom_tab_bar.dart';

// 동기화 상태 관리를 위한 Provider
final StateNotifierProvider<SyncingStateNotifier, bool> syncingStateProvider =
    StateNotifierProvider<SyncingStateNotifier, bool>(
      (Ref ref) => SyncingStateNotifier(),
    );

class SyncingStateNotifier extends StateNotifier<bool> {
  SyncingStateNotifier() : super(false);

  void setSyncing(bool value) => state = value;
}

// 워크아웃 데이터 관리를 위한 Provider
final StateNotifierProvider<WorkoutDataNotifier, List<WorkoutRecord>>
workoutDataProvider =
    StateNotifierProvider<WorkoutDataNotifier, List<WorkoutRecord>>(
      (Ref ref) => WorkoutDataNotifier(),
    );

class WorkoutDataNotifier extends StateNotifier<List<WorkoutRecord>> {
  WorkoutDataNotifier() : super(<WorkoutRecord>[]);

  void updateWorkouts(List<WorkoutRecord> workouts) => state = workouts;
  void clearWorkouts() => state = <WorkoutRecord>[];
}

// 별도의 RefreshButton 위젯
class _RefreshButton extends ConsumerWidget {
  const _RefreshButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSyncing = ref.watch(syncingStateProvider);

    return isSyncing
        ? const Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        )
        : CustomIconButton(
          onTap: () => _performSync(ref, context),
          icon: Icons.refresh,
        );
  }

  // 실제 동기화 메서드
  Future<void> _performSync(WidgetRef ref, BuildContext context) async {
    final SyncingStateNotifier syncNotifier = ref.read(
      syncingStateProvider.notifier,
    );

    if (ref.read(syncingStateProvider)) return; // 이미 동기화 중이면 중단

    syncNotifier.setSyncing(true);

    try {
      final WorkoutSyncFacade facade = ref.read(workoutSyncFacadeProvider);
      final AppResult<Map<String, dynamic>> result =
          await facade.performFullSync();

      syncNotifier.setSyncing(false);

      if (context.mounted) {
        if (result.isSuccess) {
          final Map<String, dynamic> data = result.dataOrNull!;
          final List<WorkoutRecord> allWorkouts =
              data['allWorkouts'] as List<WorkoutRecord>;
          final int totalSuccess = data['totalSuccess'] as int;
          final int totalAttemptsCount = data['totalAttemptsCount'] as int;
          final int totalAttempts = data['totalAttempts'] as int;

          String message;

          // 연동할 것이 없는 경우 (플랫폼 지원 안함)
          if (totalAttempts == 0) {
            message = '설정 버튼을 눌러, 동기화 설정을 먼저 해 주세요';
          } else {
            // 성공/실패 개수 기반 메시지
            if (totalSuccess == 0) {
              message = '동기화할 수 있는 데이터가 없습니다.';
            } else if (totalSuccess == totalAttemptsCount) {
              message =
                  '모든 데이터 동기화 완료! 총 ${allWorkouts.length}개의 운동 기록을 가져왔습니다.';
            } else {
              message =
                  '일부 데이터 동기화 완료! 총 ${allWorkouts.length}개의 운동 기록을 가져왔습니다.';
            }
          }

          // WorkoutListScreen에 데이터 전달을 위해 Provider 업데이트
          if (allWorkouts.isNotEmpty) {
            ref.read(workoutDataProvider.notifier).updateWorkouts(allWorkouts);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('동기화 실패: ${result.exceptionOrNull?.message}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      syncNotifier.setSyncing(false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('동기화 중 오류가 발생했습니다.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

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
    return CustomAppBar(
      title: '기록',
      actions: <Widget>[
        // Refresh 버튼은 별도 위젯으로 분리하여 상태 관리
        const _RefreshButton(),
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
