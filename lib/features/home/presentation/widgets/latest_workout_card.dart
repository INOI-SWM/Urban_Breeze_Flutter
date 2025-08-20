import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/card/card_list.dart';
import 'package:urban_breeze/shared/design_system/widgets/thumbnail/thumbnail.dart';

class LatestWorkoutCard extends StatelessWidget {
  const LatestWorkoutCard({super.key, this.onMorePressed});
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    // 더미 데이터
    const String routeThumbnail = 'assets/images/png/thumbnail_r3_2.png';
    const String title = '한강 순환 코스';
    const String subtitle = '어제';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '최근 운동',
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
        const CardList(
          thumbnailPath: routeThumbnail,
          sourceType: ThumbnailSourceType.asset,
          title: title,
          createDate: subtitle,
          badges: <BadgeData>[
            BadgeData(text: '34.6 km', icon: Icons.route),
            BadgeData(text: '1시간 42분', icon: Icons.access_time),
          ],
        ),
      ],
    );
  }
}
