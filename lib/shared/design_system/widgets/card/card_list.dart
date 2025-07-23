import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/badge/content_badge.dart';
import 'package:ridingmate/shared/design_system/widgets/thumbnail/thumbnail.dart';

class BadgeData {
  const BadgeData({required this.text, required this.icon});

  final String text;
  final IconData icon;
}

class CardList extends StatelessWidget {
  const CardList({
    super.key,
    required this.thumbnailPath,
    required this.sourceType,
    required this.title,
    required this.createDate,
    required this.badges,
  });

  final String thumbnailPath;
  final ThumbnailSourceType sourceType;
  final String title;
  final String createDate;
  final List<BadgeData> badges;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Row(
      children: <Widget>[
        SizedBox(
          height: 64,
          child: Thumbnail(
            path: thumbnailPath,
            ratio: ThumbnailRatio.r3_2,
            sourceType: sourceType,
            hasRadius: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: AppTextStyles.body2.normalBold.copyWith(
                      color: colors.labelNormal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    createDate,
                    style: AppTextStyles.label2.medium.copyWith(
                      color: colors.labelAlternative,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children:
                    badges
                        .map(
                          (BadgeData badge) => ContentBadge(
                            text: badge.text,
                            type: ContentBadgeType.solid,
                            backgroundColor: colors.fillNormal,
                            textColor: colors.labelAlternative,
                            leftIcon: badge.icon,
                            size: ContentBadgeSize.xsmall,
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
