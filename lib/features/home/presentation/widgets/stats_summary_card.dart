import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_item.dart';

class StatsSummaryCard extends StatelessWidget {
  const StatsSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '이번 주 요약',
          style: AppTextStyles.title3.bold.copyWith(color: colors.labelStrong),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.backgroundElevatedNormal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: <Widget>[
              Expanded(child: InfoItem(label: '거리', value: '128.4 km')),
              Expanded(child: InfoItem(label: '운동 시간', value: '6시간 23분')),
              Expanded(child: InfoItem(label: '상승 고도', value: '920 m')),
            ],
          ),
        ),
      ],
    );
  }
}
