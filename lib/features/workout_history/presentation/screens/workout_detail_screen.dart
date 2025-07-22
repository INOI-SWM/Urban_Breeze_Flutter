import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/workout_history/domain/entities/workout_record.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';
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
            Text(
              DateFormatter.formatKorean(workoutRecord.startTime),
              style: AppTextStyles.label2.bold.copyWith(
                color: colors.labelAlternative,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  bottom: BorderSide(color: colors.lineNormalNormal, width: 1),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
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
            ),
          ],
        ),
      ),
    );
  }
}
