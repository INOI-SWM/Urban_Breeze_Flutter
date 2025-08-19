import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_record.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/utils/date_formatter.dart';
import 'package:urban_breeze/shared/utils/workout_formatter.dart';

class WorkoutDetailStatScreen extends StatelessWidget {
  const WorkoutDetailStatScreen({
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
        title: '상세 정보',
        leading: CustomIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '운동 기록 ${workoutIndex + 1}',
              style: AppTextStyles.headline1.bold.copyWith(
                color: colors.labelStrong,
              ),
            ),
            Text(
              '${DateFormatter.formatKorean(workoutRecord.startTime)} ~ ${DateFormatter.formatKorean(workoutRecord.endTime)}',
              style: AppTextStyles.body2.readingMedium.copyWith(
                color: colors.labelNormal,
              ),
            ),
            const SizedBox(height: 16),
            ..._getStatItems()
                .map(
                  (Map<String, String> item) => <Widget>[
                    _WorkoutDetailStatItem(
                      label: item['label']!,
                      value: item['value']!,
                    ),
                    const SizedBox(height: 12),
                  ],
                )
                .expand((List<Widget> widget) => widget),
          ],
        ),
      ),
    );
  }

  /// TODO: api 연동 후 수정
  List<Map<String, String>> _getStatItems() {
    // 심박수 데이터 계산

    return <Map<String, String>>[
      <String, String>{
        'label': '거리',
        'value': WorkoutFormatter.toKmText(workoutRecord.distance),
      },
      <String, String>{
        'label': '최고속도',
        'value': WorkoutFormatter.toMaxSpeedText(null),
      }, // 데이터 없음
      <String, String>{
        'label': '평균속도',
        'value': WorkoutFormatter.toSpeedText(
          workoutRecord.distance,
          workoutRecord.duration,
        ),
      },
      <String, String>{
        'label': '상승고도',
        'value': WorkoutFormatter.toAltitudeText(null),
      }, // 데이터 없음
      <String, String>{
        'label': '하강고도',
        'value': WorkoutFormatter.toAltitudeText(null),
      }, // 데이터 없음
      <String, String>{
        'label': '전체시간',
        'value': WorkoutFormatter.toDurationText(workoutRecord.duration),
      },
      <String, String>{
        'label': '운동시간',
        'value': WorkoutFormatter.toDurationText(workoutRecord.duration),
      },
      <String, String>{
        'label': '케이던스',
        'value': WorkoutFormatter.toCadenceText(null),
      }, // 데이터 없음
      <String, String>{
        'label': '평균 심박수',
        'value': WorkoutFormatter.toHeartRateText(
          workoutRecord.heartRateData?.first.heartRate.toDouble(),
        ),
      },
      <String, String>{
        'label': '최대 심박수',
        'value': WorkoutFormatter.toHeartRateText(
          workoutRecord.heartRateData?.last.heartRate.toDouble(),
        ),
      },
      <String, String>{
        'label': '평균 파워',
        'value': WorkoutFormatter.toPowerText(null),
      }, // 데이터 없음
      <String, String>{
        'label': '최고파워',
        'value': WorkoutFormatter.toPowerText(null),
      }, // 데이터 없음
      <String, String>{
        'label': '소모 칼로리',
        'value': WorkoutFormatter.toCaloriesText(workoutRecord.calories),
      },
    ];
  }
}

class _WorkoutDetailStatItem extends StatelessWidget {
  const _WorkoutDetailStatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.label1.readingBold.copyWith(
            color: colors.labelAlternative,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body1.readingBold.copyWith(
            color: colors.labelNormal,
          ),
        ),
      ],
    );
  }
}
