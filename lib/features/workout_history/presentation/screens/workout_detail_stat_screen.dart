import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/workout_history/domain/entities/heart_rate_data.dart';
import 'package:ridingmate/features/workout_history/domain/entities/workout_record.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:ridingmate/shared/utils/date_formatter.dart';

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
    final double avgHeartRate =
        workoutRecord.heartRateData.isNotEmpty
            ? (workoutRecord.heartRateData
                        .map((HeartRateData data) => data.heartRate)
                        .reduce((int a, int b) => a + b) /
                    workoutRecord.heartRateData.length)
                .toDouble()
            : 0;
    final double maxHeartRate =
        workoutRecord.heartRateData.isNotEmpty
            ? workoutRecord.heartRateData
                .map((HeartRateData data) => data.heartRate)
                .reduce((int a, int b) => a > b ? a : b)
                .toDouble()
            : 0;

    return <Map<String, String>>[
      <String, String>{
        'label': '거리',
        'value': '${(workoutRecord.distance / 1000).toStringAsFixed(1)} km',
      },
      <String, String>{'label': '최고속도', 'value': '24.0 km/h'},
      <String, String>{
        'label': '평균속도',
        'value':
            '${(workoutRecord.distance / 1000 / (workoutRecord.duration.inMinutes / 60)).toStringAsFixed(1)} km/h',
      },
      <String, String>{'label': '상승고도', 'value': '124 m'}, // 임의 값
      <String, String>{'label': '하강고도', 'value': '118 m'}, // 임의 값
      <String, String>{
        'label': '전체시간',
        'value':
            '${workoutRecord.duration.inMinutes}분 ${workoutRecord.duration.inSeconds % 60}초',
      },
      <String, String>{
        'label': '운동시간',
        'value':
            '${workoutRecord.duration.inMinutes}분 ${workoutRecord.duration.inSeconds % 60}초',
      },
      <String, String>{'label': '케이던스', 'value': '85 rpm'}, // 임의 값
      <String, String>{
        'label': '평균 심박수',
        'value': avgHeartRate > 0 ? '${avgHeartRate.round()} bpm' : '-- bpm',
      },
      <String, String>{
        'label': '최대 심박수',
        'value': maxHeartRate > 0 ? '${maxHeartRate.round()} bpm' : '-- bpm',
      },
      <String, String>{'label': '평균 파워', 'value': '180 W'}, // 임의 값
      <String, String>{'label': '최고파워', 'value': '320 W'}, // 임의 값
      <String, String>{
        'label': '소모 칼로리',
        'value': '${workoutRecord.calories.round()} kcal',
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
