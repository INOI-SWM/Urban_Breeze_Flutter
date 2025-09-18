import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_activity.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
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
import 'package:urban_breeze/shared/utils/date_formatter.dart';
import 'package:urban_breeze/shared/utils/workout_formatter.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workoutIndex,
    required this.workoutActivity,
  });

  final int workoutIndex;
  final WorkoutActivity workoutActivity;

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
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
          'workout_id': widget.workoutActivity.id,
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

    final AppResult<WorkoutDetail> result = await ref
        .read(getWorkoutDetailUseCaseProvider)
        .execute(activityId: widget.workoutActivity.id.toString());

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
          onTap: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          CustomIconButton(
            icon: Icons.more_vert,
            onTap: () {
              AmplitudeAnalytics.logButtonClick(
                'workout_detail_more_options',
                additionalProperties: <String, dynamic>{
                  'workout_id': widget.workoutActivity.id,
                },
              );
              // TODO: 더보기 메뉴 구현
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
                      const Expanded(
                        child: InfoItem(
                          label: '소모 칼로리',
                          value: '--', // TODO: 칼로리 데이터 추가 필요
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
                          label: '전체 시간',
                          value: WorkoutFormatter.toDurationText(
                            detail.totalDuration,
                          ),
                          alignment: CrossAxisAlignment.start,
                        ),
                      ),
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

                        // TODO: WorkoutDetailStatScreen을 WorkoutActivity 지원하도록 수정 필요
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute<void>(
                        //     builder: (BuildContext context) => WorkoutDetailStatScreen(
                        //       workoutIndex: widget.workoutIndex,
                        //       workoutRecord: widget.workoutActivity,
                        //     ),
                        //   ),
                        // );
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

                        // TODO: WorkoutDetailRouteScreen을 WorkoutActivity 지원하도록 수정 필요
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute<void>(
                        //     builder: (BuildContext context) => WorkoutDetailRouteScreen(
                        //       workoutRecord: widget.workoutActivity,
                        //     ),
                        //   ),
                        // );
                      },
                      textColor: colors.labelNormal,
                      borderColor: colors.lineNormalNormal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const WorkoutPhotoGalleryWidget(),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
