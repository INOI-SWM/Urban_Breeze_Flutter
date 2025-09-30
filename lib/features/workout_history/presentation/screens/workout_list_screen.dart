import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_activity.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_list.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/workout_sort_type.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/card/card_list.dart';
import 'package:urban_breeze/shared/design_system/widgets/chip/chip_action.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/design_system/widgets/thumbnail/thumbnail.dart';
import 'package:urban_breeze/shared/sort/sort_modal.dart';

import 'workout_detail_screen.dart';

class WorkoutListScreen extends ConsumerStatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  ConsumerState<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

enum ViewMode { list, grid }

class _ViewModeToggleButton extends StatelessWidget {
  const _ViewModeToggleButton({required this.viewMode, required this.onToggle});

  final ViewMode viewMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return CustomIconButton(
      icon: viewMode == ViewMode.list ? Icons.grid_view : Icons.list,
      onTap: onToggle,
      color: colors.labelNormal,
    );
  }
}

class _EmptyWorkoutState extends StatelessWidget {
  const _EmptyWorkoutState();

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.info_outline, size: 48, color: colors.labelAlternative),
        const SizedBox(height: 8),
        Text('운동 데이터가 없습니다', style: AppTextStyles.body2.normalBold),
        const SizedBox(height: 4),
        Text(
          '먼저 권한을 요청하고 데이터를 불러오세요',
          style: AppTextStyles.label2.medium.copyWith(
            color: colors.labelAlternative,
          ),
        ),
      ],
    );
  }
}

class _WorkoutListItem extends StatelessWidget {
  const _WorkoutListItem({
    required this.workout,
    required this.index,
    required this.onTap,
  });

  final WorkoutActivity workout;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CardList(
        thumbnailPath:
            workout.thumbnailImageUrl.isNotEmpty
                ? workout.thumbnailImageUrl
                : 'assets/images/png/thumbnail_r3_2.png',
        sourceType:
            workout.thumbnailImageUrl.isNotEmpty
                ? ThumbnailSourceType.network
                : ThumbnailSourceType.asset,
        title: workout.title.isNotEmpty ? workout.title : '운동 ${index + 1}',
        createDate: workout.startedAtDisplay,
        badges: <BadgeData>[
          BadgeData(text: workout.distanceDisplay, icon: Icons.route),
          BadgeData(
            text: workout.elevationGainDisplay,
            icon: Icons.trending_up,
          ),
          BadgeData(text: workout.durationDisplay, icon: Icons.access_time),
        ],
        onTap: onTap,
      ),
    );
  }
}

class _WorkoutGridItem extends StatelessWidget {
  const _WorkoutGridItem({
    required this.workout,
    required this.index,
    required this.onTap,
  });

  final WorkoutActivity workout;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Thumbnail(
        path:
            workout.thumbnailImageUrl.isNotEmpty
                ? workout.thumbnailImageUrl
                : 'assets/images/png/thumbnail_r1_1.png',
        ratio: ThumbnailRatio.square,
        sourceType:
            workout.thumbnailImageUrl.isNotEmpty
                ? ThumbnailSourceType.network
                : ThumbnailSourceType.asset,
        hasRadius: false,
      ),
    );
  }
}

class _WorkoutListScreenState extends ConsumerState<WorkoutListScreen> {
  WorkoutList workoutList = WorkoutList.empty();
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  ViewMode _viewMode = ViewMode.list;
  WorkoutSortType _sortType = WorkoutSortType.startedAtDesc;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadWorkoutList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('workout_list_screen');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadMoreWorkouts();
    }
  }

  /// 현재 뷰 모드에 따른 페이지 사이즈 반환
  int _getPageSize() {
    return _viewMode == ViewMode.grid ? 21 : 10; // 그리드: 21개(3x7), 리스트: 10개
  }

  /// 뷰 모드 전환 시 필요한 데이터가 부족하면 추가 로딩
  Future<void> _ensureEnoughDataForViewMode(ViewMode newMode) async {
    final int requiredSize = newMode == ViewMode.grid ? 21 : 10;
    final int currentSize = workoutList.activities.length;

    if (currentSize < requiredSize && workoutList.hasNext) {
      await _loadMoreToTargetSize(requiredSize);
    }
  }

  /// 목표 사이즈까지 데이터 로딩
  Future<void> _loadMoreToTargetSize(int targetSize) async {
    while (workoutList.activities.length < targetSize &&
        workoutList.hasNext &&
        !isLoadingMore) {
      await _loadMoreWorkouts();
    }
  }

  Future<void> _onViewModeChanged(ViewMode newMode) async {
    if (_viewMode == newMode) return;
    await _ensureEnoughDataForViewMode(newMode);

    setState(() {
      _viewMode = newMode;
    });
  }

  Future<void> _loadWorkoutList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final AppResult<WorkoutList> result = await ref
        .read(getWorkoutListUseCaseProvider)
        .execute(page: 0, size: _getPageSize(), sortType: _sortType);

    setState(() {
      isLoading = false;
      if (result.isSuccess) {
        workoutList = result.dataOrNull!;
      } else {
        errorMessage = '서버에러';
        workoutList = WorkoutList.empty();
      }
    });
  }

  Future<void> _loadMoreWorkouts() async {
    if (isLoadingMore || !workoutList.hasNext) return;

    setState(() {
      isLoadingMore = true;
    });

    final AppResult<WorkoutList> result = await ref
        .read(getWorkoutListUseCaseProvider)
        .execute(
          page: workoutList.currentPage + 1,
          size: _getPageSize(),
          sortType: _sortType,
        );

    setState(() {
      isLoadingMore = false;
      if (result.isSuccess) {
        final WorkoutList newWorkoutList = result.dataOrNull!;
        workoutList = WorkoutList(
          activities: <WorkoutActivity>[
            ...workoutList.activities,
            ...newWorkoutList.activities,
          ],
          currentPage: newWorkoutList.currentPage,
          totalPages: newWorkoutList.totalPages,
          totalElements: newWorkoutList.totalElements,
          size: newWorkoutList.size,
          hasNext: newWorkoutList.hasNext,
          hasPrevious: newWorkoutList.hasPrevious,
        );
      }
    });
  }

  Future<void> _navigateToWorkoutDetail(
    WorkoutActivity workout,
    int index,
  ) async {
    AmplitudeAnalytics.logEvent(
      'workout_record_clicked',
      properties: <String, dynamic>{'workout_id': workout.activityId},
    );

    final dynamic result = await Navigator.push(
      context,
      MaterialPageRoute<dynamic>(
        builder:
            (BuildContext context) => WorkoutDetailScreen(
              workoutActivity: workout,
              workoutIndex: index,
            ),
      ),
    );

    // 제목이 수정된 경우 리스트 아이템 업데이트
    if (result != null && result is WorkoutDetail) {
      _updateWorkoutTitle(index, result.title);
    }
    // 삭제된 경우 리스트에서 해당 아이템 제거
    else if (result == true) {
      _removeWorkoutFromList(index);
    }
  }

  void _updateWorkoutTitle(int index, String newTitle) {
    if (index < 0 || index >= workoutList.activities.length) return;

    final WorkoutActivity oldActivity = workoutList.activities[index];
    final WorkoutActivity updatedActivity = WorkoutActivity(
      activityId: oldActivity.activityId,
      title: newTitle, // 새로운 제목으로 업데이트
      startedAt: oldActivity.startedAt,
      endedAt: oldActivity.endedAt,
      distance: oldActivity.distance,
      duration: oldActivity.duration,
      elevationGain: oldActivity.elevationGain,
      thumbnailImageUrl: oldActivity.thumbnailImageUrl,
      userProfileImageUrl: oldActivity.userProfileImageUrl,
      userNickname: oldActivity.userNickname,
    );

    final List<WorkoutActivity> updatedActivities = List<WorkoutActivity>.from(
      workoutList.activities,
    );
    updatedActivities[index] = updatedActivity;

    setState(() {
      workoutList = WorkoutList(
        activities: updatedActivities,
        currentPage: workoutList.currentPage,
        totalPages: workoutList.totalPages,
        totalElements: workoutList.totalElements,
        size: workoutList.size,
        hasNext: workoutList.hasNext,
        hasPrevious: workoutList.hasPrevious,
      );
    });
  }

  void _removeWorkoutFromList(int index) {
    if (index < 0 || index >= workoutList.activities.length) return;

    final List<WorkoutActivity> updatedActivities = List<WorkoutActivity>.from(
      workoutList.activities,
    );
    updatedActivities.removeAt(index);

    setState(() {
      workoutList = WorkoutList(
        activities: updatedActivities,
        currentPage: workoutList.currentPage,
        totalPages: workoutList.totalPages,
        totalElements: workoutList.totalElements - 1, // 총 개수 1 감소
        size: workoutList.size,
        hasNext: workoutList.hasNext,
        hasPrevious: workoutList.hasPrevious,
      );
    });
  }

  void _showSortModal() {
    SortModal.show<WorkoutSortType>(
      context: context,
      options: WorkoutSortType.values,
      selectedOption: _sortType,
      onOptionSelected: (WorkoutSortType sortType) {
        setState(() {
          _sortType = sortType;
        });

        AmplitudeAnalytics.logEvent(
          'workout_sort_changed',
          properties: <String, dynamic>{
            'sort_type': sortType.name,
            'sort_display_name': sortType.displayName,
          },
        );

        _loadWorkoutList();
      },
      getDisplayText: (WorkoutSortType option) => option.displayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (workoutList.activities.isNotEmpty) ...<Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ChipAction(
                  text: _sortType.displayName,
                  rightIcon: Icons.expand_more,
                  size: ChipActionSize.xsmall,
                  type: ChipActionType.outlined,
                  textColor: context.semanticColor.labelNormal,
                  borderColor: context.semanticColor.lineNormalNormal,
                  onPressed: _showSortModal,
                ),
                _ViewModeToggleButton(
                  viewMode: _viewMode,
                  onToggle: () async {
                    // 뷰 모드 변경 이벤트
                    final ViewMode newViewMode =
                        _viewMode == ViewMode.list
                            ? ViewMode.grid
                            : ViewMode.list;

                    AmplitudeAnalytics.logEvent(
                      'workout_view_mode_changed',
                      properties: <String, dynamic>{
                        'view_mode': newViewMode.name,
                      },
                    );

                    // 새로운 뷰 모드에 필요한 데이터 확보 후 전환
                    await _onViewModeChanged(newViewMode);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Expanded(child: _buildResultWidget()),
        ],
      ),
    );
  }

  Widget _buildResultWidget() {
    if (isLoading) {
      return const Center(child: AppLoadingIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (workoutList.activities.isEmpty) {
      return const _EmptyWorkoutState();
    }

    return _viewMode == ViewMode.list
        ? ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: workoutList.activities.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index == workoutList.activities.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: AppLoadingIndicator()),
              );
            }

            final WorkoutActivity workout = workoutList.activities[index];
            return _WorkoutListItem(
              workout: workout,
              index: index,
              onTap: () => _navigateToWorkoutDetail(workout, index),
            );
          },
        )
        : GridView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            childAspectRatio: 1.0,
          ),
          itemCount: workoutList.activities.length + (isLoadingMore ? 3 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (index >= workoutList.activities.length) {
              return const Center(child: AppLoadingIndicator());
            }

            final WorkoutActivity workout = workoutList.activities[index];
            return _WorkoutGridItem(
              workout: workout,
              index: index,
              onTap: () => _navigateToWorkoutDetail(workout, index),
            );
          },
        );
  }
}
