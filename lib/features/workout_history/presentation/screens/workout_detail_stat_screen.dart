import 'package:flutter/material.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
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
    required this.workoutDetail,
  });

  final int workoutIndex;
  final WorkoutDetail workoutDetail;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView(
        'workout_detail_stat_screen',
        additionalProperties: <String, dynamic>{
          'workout_id': workoutDetail.id,
          'workout_index': workoutIndex,
        },
      );
    });

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: CustomAppBar(
        title: '상세 정보',
        leading: CustomIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildStatContent(colors),
    );
  }

  Widget _buildStatContent(SemanticColors colors) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            workoutDetail.title,
            style: AppTextStyles.headline1.bold.copyWith(
              color: colors.labelStrong,
            ),
          ),
          Text(
            '${DateFormatter.formatKorean(workoutDetail.startedAt)} ~ ${DateFormatter.formatKorean(workoutDetail.endedAt)}',
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
    );
  }

  List<Map<String, String>> _getStatItems() {
    return <Map<String, String>>[
      <String, String>{
        'label': '거리',
        'value': WorkoutFormatter.toKmTextFromKm(workoutDetail.distance),
      },
      <String, String>{
        'label': '평균속도',
        'value': workoutDetail.averageSpeedDisplay,
      },
      <String, String>{
        'label': '상승고도',
        'value': workoutDetail.elevationGainDisplay,
      },
      <String, String>{
        'label': '운동시간',
        'value': WorkoutFormatter.toDurationText(workoutDetail.activeDuration),
      },
      <String, String>{'label': '케이던스', 'value': workoutDetail.cadenceDisplay},
      <String, String>{
        'label': '평균 심박수',
        'value': workoutDetail.averageHeartRateDisplay,
      },
      <String, String>{
        'label': '최대 심박수',
        'value': workoutDetail.maxHeartRateDisplay,
      },
      <String, String>{
        'label': '평균 파워',
        'value': workoutDetail.averagePowerDisplay,
      },
      <String, String>{'label': '최고파워', 'value': workoutDetail.maxPowerDisplay},
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
