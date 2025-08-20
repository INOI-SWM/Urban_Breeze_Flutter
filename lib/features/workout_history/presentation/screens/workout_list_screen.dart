import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/workout_history/presentation/pages/workout_history_page.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/workout_detail_screen.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/card/card_list.dart';
import 'package:urban_breeze/shared/design_system/widgets/chip/chip_action.dart';
import 'package:urban_breeze/shared/design_system/widgets/thumbnail/thumbnail.dart';
import 'package:urban_breeze/shared/sort/sort_modal.dart';
import 'package:urban_breeze/shared/utils/date_formatter.dart';
import 'package:urban_breeze/shared/utils/workout_formatter.dart';

import '../../domain/entities/workout_record.dart';
import '../../domain/enums/workout_sort_type.dart';

//TODO : 추후 api 개발 시 에러 처리 추가
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Center(
      child: Text(
        '데이터를 불러오는 중...',
        style: AppTextStyles.label2.medium.copyWith(
          color: colors.labelAlternative,
        ),
      ),
    );
  }
}

class _WorkoutListItem extends StatelessWidget {
  const _WorkoutListItem({
    required this.workout,
    required this.index,
    required this.onTap,
  });

  final WorkoutRecord workout;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CardList(
        thumbnailPath: 'assets/images/png/thumbnail_r3_2.png',
        sourceType: ThumbnailSourceType.asset,
        title: '운동 ${index + 1}',
        createDate: DateFormatter.formatKorean(workout.startTime),
        badges: <BadgeData>[
          BadgeData(
            text: WorkoutFormatter.toKmText(workout.distance),
            icon: Icons.route,
          ),
          BadgeData(
            text: WorkoutFormatter.toDurationText(workout.duration),
            icon: Icons.access_time,
          ),
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

  final WorkoutRecord workout;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Thumbnail(
        path: 'assets/images/png/thumbnail_r1_1.png',
        ratio: ThumbnailRatio.square,
        sourceType: ThumbnailSourceType.asset,
        hasRadius: false,
      ),
    );
  }
}

class _WorkoutListScreenState extends ConsumerState<WorkoutListScreen> {
  final bool _isLoading = false;
  List<WorkoutRecord> _workouts = <WorkoutRecord>[];
  ViewMode _viewMode = ViewMode.list;
  WorkoutSortType _sortType = WorkoutSortType.newest;

  @override
  void initState() {
    super.initState();
  }

  // 데이터 업데이트 메서드
  void _updateWorkouts(List<WorkoutRecord> workouts) {
    setState(() {
      _workouts = _sortWorkouts(workouts);
    });
  }

  void _navigateToWorkoutDetail(WorkoutRecord workout, int index) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (BuildContext context) => WorkoutDetailScreen(
              workoutRecord: workout,
              workoutIndex: index,
            ),
      ),
    );
  }

  void _showSortModal() {
    SortModal.show<WorkoutSortType>(
      context: context,
      options: WorkoutSortType.values,
      selectedOption: _sortType,
      onOptionSelected: (WorkoutSortType sortType) {
        setState(() {
          _sortType = sortType;
          _workouts = _sortWorkouts(_workouts);
        });
      },
      getDisplayText: (WorkoutSortType option) => option.displayName,
    );
  }

  // todo : api 개발 시 삭제 예정
  List<WorkoutRecord> _sortWorkouts(List<WorkoutRecord> workouts) {
    final List<WorkoutRecord> sortedWorkouts = List<WorkoutRecord>.from(
      workouts,
    );

    switch (_sortType) {
      case WorkoutSortType.newest:
        sortedWorkouts.sort(
          (WorkoutRecord a, WorkoutRecord b) =>
              b.startTime.compareTo(a.startTime),
        );
        break;
      case WorkoutSortType.oldest:
        sortedWorkouts.sort(
          (WorkoutRecord a, WorkoutRecord b) =>
              a.startTime.compareTo(b.startTime),
        );
        break;
      case WorkoutSortType.distance:
        sortedWorkouts.sort(
          (WorkoutRecord a, WorkoutRecord b) =>
              b.distance.compareTo(a.distance),
        );
        break;
    }

    return sortedWorkouts;
  }

  @override
  Widget build(BuildContext context) {
    // Provider에서 워크아웃 데이터 감지
    final List<WorkoutRecord> providerWorkouts = ref.watch(workoutDataProvider);

    // Provider에서 새 데이터가 있으면 업데이트
    if (providerWorkouts.isNotEmpty && providerWorkouts != _workouts) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateWorkouts(providerWorkouts);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // 결과 표시
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _buildResultWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildResultWidget() {
    if (_workouts.isEmpty && !_isLoading) {
      return const _EmptyWorkoutState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (_workouts.isNotEmpty) ...<Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
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
                  onToggle: () {
                    setState(() {
                      _viewMode =
                          _viewMode == ViewMode.list
                              ? ViewMode.grid
                              : ViewMode.list;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child:
                _viewMode == ViewMode.list
                    ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _workouts.length,
                      itemBuilder: (BuildContext context, int index) {
                        final WorkoutRecord workout = _workouts[index];
                        return _WorkoutListItem(
                          workout: workout,
                          index: index,
                          onTap: () => _navigateToWorkoutDetail(workout, index),
                        );
                      },
                    )
                    : GridView.builder(
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 1,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: _workouts.length,
                      itemBuilder: (BuildContext context, int index) {
                        final WorkoutRecord workout = _workouts[index];
                        return _WorkoutGridItem(
                          workout: workout,
                          index: index,
                          onTap: () => _navigateToWorkoutDetail(workout, index),
                        );
                      },
                    ),
          ),
        ] else ...<Widget>[const _LoadingState()],
      ],
    );
  }
}
