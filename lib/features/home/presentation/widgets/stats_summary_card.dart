import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_items_row.dart';

class StatsSummaryCard extends StatelessWidget {
  const StatsSummaryCard({super.key, this.onMorePressed});
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '이번 주 라이딩 요약',
              style: AppTextStyles.heading2.bold.copyWith(
                color: colors.labelStrong,
              ),
            ),
            GestureDetector(
              onTap: onMorePressed,
              child: Text(
                '더보기',
                style: AppTextStyles.label1.normalBold.copyWith(
                  color: colors.labelAlternative,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colors.backgroundElevatedNormal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const InfoItemsRow(
            items: <InfoItemData>[
              InfoItemData(label: '거리', value: '128.4 km'),
              InfoItemData(label: '운동 시간', value: '6시간 23분'),
              InfoItemData(label: '상승 고도', value: '920 m'),
            ],
          ),
        ),
      ],
    );
  }
}
