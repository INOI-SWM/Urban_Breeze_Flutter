import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_record.dart';
import 'package:urban_breeze/features/workout_history/presentation/notifiers/workout_refresh_notifier.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/sync_screen.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/workout_list_screen.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/workout_statics_screen.dart';
import 'package:urban_breeze/navigation/navigation_providers.dart';
import 'package:urban_breeze/navigation/page_with_app_bar.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_size.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_solid.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/design_system/widgets/tab_bar/custom_tab_bar.dart';

// 동기화 상태 관리를 위한 Provider
final StateNotifierProvider<SyncingStateNotifier, bool> syncingStateProvider =
    StateNotifierProvider<SyncingStateNotifier, bool>(
      (Ref ref) => SyncingStateNotifier(),
    );

// 동기화 완료 이벤트를 관리하는 Provider
final StateNotifierProvider<SyncCompleteNotifier, int> syncCompleteProvider =
    StateNotifierProvider<SyncCompleteNotifier, int>(
      (Ref ref) => SyncCompleteNotifier(),
    );

class SyncingStateNotifier extends StateNotifier<bool> {
  SyncingStateNotifier() : super(false);

  void setSyncing(bool value) => state = value;
}

class SyncCompleteNotifier extends StateNotifier<int> {
  SyncCompleteNotifier() : super(0);

  void triggerSyncComplete() => state = state + 1;
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
            child: AppLoadingIndicator(strokeWidth: 2),
          ),
        )
        : CustomIconButton(
          onTap: () => _performSync(ref, context),
          icon: Icons.refresh,
        );
  }

  // 실제 동기화 메서드
  Future<void> _performSync(WidgetRef ref, BuildContext context) async {
    if (ref.read(syncingStateProvider)) return; // 이미 동기화 중이면 중단

    // 모달 표시 (모달 내부에서 새로고침 처리)
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const SyncModal(),
    );
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

/// 동기화 모달 위젯
class SyncModal extends ConsumerStatefulWidget {
  const SyncModal({super.key});

  @override
  ConsumerState<SyncModal> createState() => _SyncModalState();
}

class _SyncModalState extends ConsumerState<SyncModal> {
  @override
  void initState() {
    super.initState();
    // initState에서 provider 수정을 피하기 위해 WidgetsBinding.instance.addPostFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSync();
    });
  }

  Future<void> _startSync() async {
    final SyncingStateNotifier syncNotifier = ref.read(
      syncingStateProvider.notifier,
    );

    syncNotifier.setSyncing(true);

    // WorkoutRefreshNotifier를 사용하여 새로고침 수행
    final WorkoutRefreshNotifier refreshNotifier = ref.read(
      workoutRefreshNotifierProvider.notifier,
    );
    await refreshNotifier.performRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final WorkoutRefreshState refreshState = ref.watch(
      workoutRefreshNotifierProvider,
    );

    // 동기화 완료 시 syncingState 업데이트
    if (!refreshState.isRefreshing && refreshState.syncStatus != null) {
      Future<void>.microtask(() {
        ref.read(syncingStateProvider.notifier).setSyncing(false);
      });
    }

    return PopScope(
      canPop: !refreshState.isRefreshing, // 동기화 중일 때는 뒤로 가기 막기
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.backgroundElevatedNormal,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 상태 표시
            if (refreshState.isRefreshing) ...<Widget>[
              const AppLoadingIndicator(),
              const SizedBox(height: 16),
            ],

            Text(
              refreshState.statusMessage.isEmpty
                  ? '동기화를 시작합니다...'
                  : refreshState.statusMessage,
              style: AppTextStyles.body1.normalBold.copyWith(
                color: colors.labelStrong,
              ),
              textAlign: TextAlign.center,
            ),

            if (refreshState.isRefreshing) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                '최대 1분 정도 걸릴 수 있습니다.',
                style: AppTextStyles.body2.normalBold.copyWith(
                  color: colors.labelAlternative,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '앱을 끄지 마세요',
                style: AppTextStyles.body2.normalBold.copyWith(
                  color: colors.labelAlternative,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // 진행 상태 표시
            if (refreshState.syncStatus != null &&
                refreshState.syncStatus!.isInProgress) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                '수신된 기록: ${refreshState.syncStatus!.receivedCount}개',
                style: AppTextStyles.caption1.medium.copyWith(
                  color: colors.labelNormal,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 24),

            // 동기화 중이 아닐 때만 닫기 버튼 표시
            if (!refreshState.isRefreshing)
              SizedBox(
                width: double.infinity,
                child: ButtonSolid(
                  text: '닫기',
                  size: ButtonSize.large,
                  backgroundColor: colors.primaryNormal,
                  textColor: colors.staticWhite,
                  onPressed: () {
                    // 모달 닫기 전에 동기화 완료 이벤트 발생
                    ref
                        .read(syncCompleteProvider.notifier)
                        .triggerSyncComplete();
                    Navigator.of(context).pop();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
