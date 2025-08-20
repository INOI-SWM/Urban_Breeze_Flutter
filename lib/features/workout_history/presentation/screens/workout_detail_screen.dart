import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_record.dart';
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
import 'package:urban_breeze/shared/utils/date_formatter.dart';
import 'package:urban_breeze/shared/utils/workout_formatter.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workoutIndex,
    required this.workoutRecord,
  });

  final int workoutIndex;
  final WorkoutRecord workoutRecord;

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
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
              // TODO: 더보기 메뉴 구현
            },
          ),
        ],
      ),
      body: GestureDetector(
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
                            DateFormatter.formatKorean(
                              widget.workoutRecord.startTime,
                            ),
                            style: AppTextStyles.label2.bold.copyWith(
                              color: colors.labelAlternative,
                            ),
                          ),
                          const SizedBox(height: 8),
                          WorkoutTitleEditWidget(
                            workoutId: widget.workoutRecord.id,
                            initialIndex: widget.workoutIndex,
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
                      WorkoutFormatter.toKmText(widget.workoutRecord.distance),
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
                              widget.workoutRecord.duration,
                            ),
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Expanded(
                          child: InfoItem(
                            label: '평균 속도',
                            value: WorkoutFormatter.toSpeedText(
                              widget.workoutRecord.distance,
                              widget.workoutRecord.duration,
                            ),
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Expanded(
                          child: InfoItem(
                            label: '소모 칼로리',
                            value: WorkoutFormatter.toCaloriesText(
                              widget.workoutRecord.calories,
                            ),
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    //TODO: api 개발 후 데이터 변경
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InfoItem(
                            label: '전체 시간',
                            value: WorkoutFormatter.toDurationText(
                              widget.workoutRecord.duration,
                            ),
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Expanded(
                          child: InfoItem(
                            label: '케이던스',
                            value: WorkoutFormatter.toCadenceText(
                              null,
                            ), // 데이터 없음
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Expanded(
                          child: InfoItem(
                            label: '평균 심박수',
                            value: WorkoutFormatter.toHeartRateText(
                              widget
                                      .workoutRecord
                                      .heartRateData
                                      ?.firstOrNull
                                      ?.heartRate
                                      .toDouble() ??
                                  0,
                            ),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder:
                                  (BuildContext context) =>
                                      WorkoutDetailStatScreen(
                                        workoutIndex: widget.workoutIndex,
                                        workoutRecord: widget.workoutRecord,
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
                      child: WorkoutDetailMapWidget(
                        workoutRecord: widget.workoutRecord,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ButtonOutlined(
                        text: '상세 경로',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder:
                                  (BuildContext context) =>
                                      WorkoutDetailRouteScreen(
                                        workoutRecord: widget.workoutRecord,
                                      ),
                            ),
                          );
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
              const SizedBox(height: 50), // 빈 공간 추가
            ],
          ),
        ),
      ),
    );
  }
}
