import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/delete_workout_use_case.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_activity.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/workout_detail_route_screen.dart';
import 'package:urban_breeze/features/workout_history/presentation/screens/workout_detail_stat_screen.dart';
import 'package:urban_breeze/features/workout_history/presentation/widgets/workout_detail_map_widget.dart';
import 'package:urban_breeze/features/workout_history/presentation/widgets/workout_photo_gallery_widget.dart';
import 'package:urban_breeze/features/workout_history/presentation/widgets/workout_title_edit_widget.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_outlined.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_item.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/design_system/widgets/modal/modal_show.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';
import 'package:urban_breeze/shared/utils/date_formatter.dart';
import 'package:urban_breeze/shared/utils/platform_action_sheet.dart';
import 'package:urban_breeze/shared/utils/workout_formatter.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    this.workoutIndex,
    this.workoutActivity,
    this.activityId,
  });

  final int? workoutIndex;
  final WorkoutActivity? workoutActivity;
  final String? activityId;

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen>
    with ErrorDisplayMixin {
  WorkoutDetail? workoutDetail;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWorkoutDetail();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView(
        'workout_detail_screen',
        additionalProperties: <String, dynamic>{
          'workout_id': widget.activityId ?? widget.workoutActivity?.activityId,
          'workout_index': widget.workoutIndex,
        },
      );
    });
  }

  Future<void> _loadWorkoutDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final String activityId =
        widget.activityId ??
        widget.workoutActivity?.activityId.toString() ??
        '';
    final AppResult<WorkoutDetail> result = await ref
        .read(getWorkoutDetailUseCaseProvider)
        .execute(activityId: activityId);

    setState(() {
      isLoading = false;
      if (result.isSuccess) {
        workoutDetail = result.dataOrNull!;
      } else {
        errorMessage = '운동 상세 정보를 불러올 수 없습니다';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: CustomAppBar(
        leading: CustomIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.of(context).pop(workoutDetail),
        ),
        actions: <Widget>[
          CustomIconButton(
            icon: Icons.more_vert,
            onTap: () {
              AmplitudeAnalytics.logButtonClick(
                'workout_detail_more_options',
                additionalProperties: <String, dynamic>{
                  'workout_id':
                      widget.activityId ?? widget.workoutActivity?.activityId,
                },
              );
              _showMoreOptionsMenu(context);
            },
          ),
        ],
      ),
      body: _buildBody(colors),
    );
  }

  Widget _buildBody(SemanticColors colors) {
    if (isLoading) {
      return const Center(child: AppLoadingIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline, size: 48, color: colors.labelAlternative),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: AppTextStyles.body2.normalBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ButtonOutlined(
              text: '다시 시도',
              onPressed: _loadWorkoutDetail,
              textColor: colors.labelNormal,
              borderColor: colors.lineNormalNormal,
            ),
          ],
        ),
      );
    }

    if (workoutDetail == null) {
      return Center(
        child: Text('운동 상세 정보가 없습니다', style: AppTextStyles.body2.normalBold),
      );
    }

    return _buildWorkoutDetailContent(colors);
  }

  Widget _buildWorkoutDetailContent(SemanticColors colors) {
    final WorkoutDetail detail = workoutDetail!;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colors.lineNormalNormal,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          DateFormatter.formatKorean(detail.startedAt),
                          style: AppTextStyles.label2.bold.copyWith(
                            color: colors.labelAlternative,
                          ),
                        ),
                        const SizedBox(height: 8),
                        WorkoutTitleEditWidget(
                          workoutId: detail.id.toString(),
                          initialTitle: detail.title,
                          currentWorkoutDetail: detail,
                          onTitleUpdated: (WorkoutDetail updatedWorkoutDetail) {
                            setState(() {
                              workoutDetail = updatedWorkoutDetail;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '이동 거리',
                    style: AppTextStyles.label1.normalBold.copyWith(
                      color: colors.labelAlternative,
                    ),
                  ),
                  Text(
                    WorkoutFormatter.toKmTextFromKm(detail.distance),
                    style: AppTextStyles.display1.bold.copyWith(
                      color: colors.labelStrong,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: InfoItem(
                          label: '운동 시간',
                          value: WorkoutFormatter.toDurationText(
                            detail.totalDuration,
                          ),
                          alignment: CrossAxisAlignment.start,
                        ),
                      ),
                      Expanded(
                        child: InfoItem(
                          label: '평균 속도',
                          value: detail.averageSpeedDisplay,
                          alignment: CrossAxisAlignment.start,
                        ),
                      ),
                      Expanded(
                        child: InfoItem(
                          label: '소모 칼로리',
                          value: detail.caloriesDisplay,
                          alignment: CrossAxisAlignment.start,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: InfoItem(
                          label: '케이던스',
                          value: detail.cadenceDisplay,
                          alignment: CrossAxisAlignment.start,
                        ),
                      ),
                      Expanded(
                        child: InfoItem(
                          label: '평균 심박수',
                          value: detail.averageHeartRateDisplay,
                          alignment: CrossAxisAlignment.start,
                        ),
                      ),
                      const Expanded(
                        child: InfoItem(
                          label: '',
                          value: '',
                          alignment: CrossAxisAlignment.start,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ButtonOutlined(
                      text: '상세 정보',
                      onPressed: () {
                        AmplitudeAnalytics.logButtonClick(
                          'workout_detail_statistics',
                          additionalProperties: <String, dynamic>{
                            'workout_id': detail.id,
                          },
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder:
                                (BuildContext context) =>
                                    WorkoutDetailStatScreen(
                                      workoutIndex: widget.workoutIndex ?? 0,
                                      workoutDetail: detail,
                                    ),
                          ),
                        );
                      },
                      textColor: colors.labelNormal,
                      borderColor: colors.lineNormalNormal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: WorkoutDetailMapWidget(workoutDetail: detail),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ButtonOutlined(
                      text: '상세 경로',
                      onPressed: () {
                        AmplitudeAnalytics.logButtonClick(
                          'workout_detail_route',
                          additionalProperties: <String, dynamic>{
                            'workout_id': detail.id,
                          },
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder:
                                (BuildContext context) =>
                                    WorkoutDetailRouteScreen(
                                      workoutDetail: detail,
                                    ),
                          ),
                        );
                      },
                      textColor: colors.labelNormal,
                      borderColor: colors.lineNormalNormal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  WorkoutPhotoGalleryWidget(
                    activityId: detail.id.toString(),
                    initialImages: detail.activityImages,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  /// 더보기 옵션 메뉴 표시
  void _showMoreOptionsMenu(BuildContext context) {
    showPlatformActionSheet(
      context,
      title: '옵션',
      options: <PlatformActionSheetOption>[
        PlatformActionSheetOption(
          title: '운동기록 삭제',
          onSelected: () {
            AmplitudeAnalytics.logEvent(
              'workout_delete',
              properties: <String, dynamic>{
                'workout_id':
                    widget.activityId ?? widget.workoutActivity?.activityId,
              },
            );
            _showDeleteConfirmDialog(context);
          },
        ),
      ],
    );
  }

  /// 삭제 확인 다이얼로그 표시
  void _showDeleteConfirmDialog(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    ModalShow.show<void>(
      context: context,
      title: '운동기록 삭제',
      content: Text(
        '이 운동기록을 삭제하시겠습니까?\n삭제된 운동기록은 복구할 수 없습니다.',
        style: AppTextStyles.body1.normalMedium.copyWith(
          color: colors.labelAlternative,
        ),
      ),
      secondaryButtonText: '취소',
      primaryButtonText: '삭제',
      onSecondaryButtonPressed: () {
        Navigator.of(context).pop();
      },
      onPrimaryButtonPressed: () => _deleteWorkout(),
      barrierDismissible: true,
      showCloseButton: false,
    );
  }

  /// 운동기록 삭제 실행
  Future<void> _deleteWorkout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (BuildContext context) =>
                const Center(child: CircularProgressIndicator()),
      );

      final DeleteWorkoutUseCase deleteWorkoutUseCase = ref.read(
        deleteWorkoutUseCaseProvider,
      );

      final String activityId =
          widget.activityId ??
          widget.workoutActivity?.activityId.toString() ??
          '';
      final AppResult<void> result = await deleteWorkoutUseCase.execute(
        activityId,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      if (result.isSuccess) {
        AmplitudeAnalytics.logEvent(
          'workout_delete_success',
          properties: <String, dynamic>{
            'workout_id':
                widget.activityId ?? widget.workoutActivity?.activityId,
          },
        );

        showSuccessMessage(context, '운동기록이 삭제되었습니다');

        Navigator.of(context).pop(true);
      } else {
        showErrorMessage(
          context,
          result.exceptionOrNull?.message ?? '운동기록 삭제에 실패했습니다',
        );
      }
    } catch (e) {
      if (!mounted) return;

      AmplitudeAnalytics.logEvent(
        'workout_delete_error',
        properties: <String, dynamic>{
          'workout_id': widget.activityId ?? widget.workoutActivity?.activityId,
          'error': e.toString(),
        },
      );

      showErrorMessage(context, '운동기록 삭제 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
