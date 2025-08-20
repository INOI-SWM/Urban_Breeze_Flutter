import 'dart:io';

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

    final List<WorkoutRecord> allWorkouts = <WorkoutRecord>[];
    int successCount = 0;
    int totalAttempts = 0;
    final List<String> errorMessages = <String>[];

    try {
      // iOS에서만 Apple Health Kit 시도
      if (Platform.isIOS) {
        totalAttempts++;
        try {
          final SyncAppleHealthKitDataUseCase appleUseCase = ref.read(
            syncAppleHealthKitDataUseCaseProvider,
          );

          // 권한 확인
          final bool hasPermission = await appleUseCase.checkPermissions();

          if (hasPermission) {
            final List<WorkoutRecord> appleWorkouts = await appleUseCase
                .fetchBasicWorkoutData(
                  startDate: DateTime.now().subtract(const Duration(days: 30)),
                  endDate: DateTime.now(),
                );
            allWorkouts.addAll(appleWorkouts);
            successCount++;
          }
        } catch (e) {
          errorMessages.add('Apple Health Kit: ${e.toString()}');
        }
      }

      // Android에서만 Google Health Connect 시도
      if (Platform.isAndroid) {
        totalAttempts++;
        try {
          final SyncGoogleHealthConnectDataUseCase googleUseCase = ref.read(
            syncGoogleHealthConnectDataUseCaseProvider,
          );

          // 권한 확인
          final bool hasPermission = await googleUseCase.checkPermissions();

          if (hasPermission) {
            final Map<WorkoutRecord, Map<String, dynamic>> completeData =
                await googleUseCase.syncCompleteWorkoutData(
                  startDate: DateTime.now().subtract(
                    const Duration(days: 1000),
                  ),
                  endDate: DateTime.now(),
                );
            allWorkouts.addAll(completeData.keys.toList());
            successCount++;
          }
        } catch (e) {
          errorMessages.add('Google Health Connect: ${e.toString()}');
        }
      }

      // 아무 플랫폼에서도 시도하지 않은 경우
      if (totalAttempts == 0) {
        errorMessages.add('지원되지 않는 플랫폼입니다. iOS 또는 Android에서만 동작합니다.');
      }

      syncNotifier.setSyncing(false);

      // 결과 메시지 표시 및 데이터 전달
      if (context.mounted) {
        String message;
        if (successCount == 0) {
          message = '동기화할 수 있는 데이터가 없습니다.\n오류: ${errorMessages.join(', ')}';
        } else if (successCount == totalAttempts) {
          message = '모든 데이터 동기화 완료! 총 ${allWorkouts.length}개의 운동 기록을 가져왔습니다.';
        } else {
          message =
              '일부 데이터 동기화 완료! 총 ${allWorkouts.length}개의 운동 기록을 가져왔습니다.\n오류: ${errorMessages.join(', ')}';
        }

        // WorkoutListScreen에 데이터 전달을 위해 Provider 업데이트
        if (allWorkouts.isNotEmpty) {
          ref.read(workoutDataProvider.notifier).updateWorkouts(allWorkouts);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 5), // 더 긴 시간 동안 메시지 표시
          ),
        );
      }
    } catch (e) {
      syncNotifier.setSyncing(false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('동기화 중 오류가 발생했습니다: ${e.toString()}'),
            duration: const Duration(seconds: 5),
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
