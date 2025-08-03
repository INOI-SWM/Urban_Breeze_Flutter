import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/workout_history/presentation/screens/workout_detail_screen.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:ridingmate/shared/design_system/widgets/card/card_list.dart';
import 'package:ridingmate/shared/design_system/widgets/chip/chip_action.dart';
import 'package:ridingmate/shared/design_system/widgets/thumbnail/thumbnail.dart';
import 'package:ridingmate/shared/sort/widgets/sort_modal.dart';
import 'package:ridingmate/shared/utils/date_formatter.dart';
import 'package:ridingmate/shared/utils/workout_formatter.dart';

import '../../data/repositories/apple_health_kit_sync_repository_impl.dart';
import '../../domain/entities/workout_record.dart';
import '../../domain/enums/workout_sort_type.dart';

//TODO : 추후 api 개발 시 에러 처리 추가
class WorkoutListScreen extends StatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  State<WorkoutListScreen> createState() => _WorkoutListScreenState();
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

class _WorkoutListScreenState extends State<WorkoutListScreen> {
  bool _isLoading = false;
  List<WorkoutRecord> _workouts = <WorkoutRecord>[];
  ViewMode _viewMode = ViewMode.list;
  WorkoutSortType _sortType = WorkoutSortType.newest;

  final AppleHealthKitSyncRepositoryImpl _repository =
      AppleHealthKitSyncRepositoryImpl();

  Future<void> _testGetCyclingWorkouts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // todo : 추후 서버 API 호출로 변경
      final List<WorkoutRecord> workouts = await _repository
          .fetchCyclingWorkoutsFromHealthKit(
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now(),
          );

      setState(() {
        _workouts = _sortWorkouts(workouts);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await _repository.requestPermissions();
    } catch (e) {
      // TODO : 권한 요청 실패 시 무시
    }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // TODO: 개발 완료 후 삭제 예정
        _buildTestButtons(),

        const SizedBox(height: 16),

        // 결과 표시
        Expanded(child: _buildResultWidget()),
      ],
    );
  }

  // TODO: 개발 완료 후 이 메서드 전체 삭제 예정
  Widget _buildTestButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _requestPermissions,
            icon: const Icon(Icons.security),
            label: const Text('권한 요청'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _testGetCyclingWorkouts,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.directions_bike),
            label: Text(_isLoading ? '로딩 중...' : ' 데이터 가져오기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
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
