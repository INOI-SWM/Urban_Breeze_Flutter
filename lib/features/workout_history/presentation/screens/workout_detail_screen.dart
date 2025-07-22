import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/workout_history/domain/entities/workout_record.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:ridingmate/shared/design_system/widgets/info/info_item.dart';
import 'package:ridingmate/shared/utils/date_formatter.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workoutIndex,
    required this.workoutRecord,
  });

  final int workoutIndex;
  final WorkoutRecord workoutRecord;

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.lineNormalNormal, width: 1),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    DateFormatter.formatKorean(workoutRecord.startTime),
                    style: AppTextStyles.label2.bold.copyWith(
                      color: colors.labelAlternative,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '운동기록 ${workoutIndex + 1}',
                        style: AppTextStyles.title3.bold.copyWith(
                          color: colors.labelStrong,
                        ),
                      ),
                      CustomIconButton(
                        icon: Icons.edit_outlined,
                        onTap: () {
                          // TODO: 편집 기능 구현
                        },
                      ),
                    ],
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
              '${(workoutRecord.distance / 1000).toStringAsFixed(1)} km',
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
                    value:
                        '${workoutRecord.duration.inMinutes}분 ${workoutRecord.duration.inSeconds % 60}초',
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  child: InfoItem(
                    label: '평균 속도',
                    value:
                        '${(workoutRecord.distance / 1000 / (workoutRecord.duration.inMinutes / 60)).toStringAsFixed(1)} km/h',
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  child: InfoItem(
                    label: '소모 칼로리',
                    value: '${workoutRecord.calories.toStringAsFixed(0)} kcal',
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
                    value: '${workoutRecord.duration.inMinutes}분',
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
                const Expanded(
                  child: InfoItem(
                    label: '케이던스',
                    value: '--',
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  child: InfoItem(
                    label: '평균 심박수',
                    value: '${workoutRecord.heartRateData.first.heartRate} bpm',
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
