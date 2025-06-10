import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/design_system/badge/content_badge.dart';
import 'package:ridingmate/design_system/thumbnail/thumbnail.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

class CardList extends StatelessWidget {
  const CardList({
    super.key,
    required this.thumbnailPath,
    required this.sourceType,
    required this.title,
    required this.createDate,
    required this.distance,
    required this.elevation,
  });

  final String thumbnailPath;
  final ThumbnailSourceType sourceType;
  final String title;
  final String createDate;
  final String distance;
  final String elevation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
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
                        color: context.semanticColor.labelNormal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createDate,
                      style: AppTextStyles.label2.medium.copyWith(
                        color: context.semanticColor.labelAlternative,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: <Widget>[
                    ContentBadge(
                      text: distance,
                      type: ContentBadgeType.solid,
                      backgroundColor: context.semanticColor.fillNormal,
                      textColor: context.semanticColor.labelAlternative,
                      leftIcon: Icons.route,
                      size: ContentBadgeSize.xsmall,
                    ),
                    ContentBadge(
                      text: elevation,
                      type: ContentBadgeType.solid,
                      backgroundColor: context.semanticColor.fillNormal,
                      textColor: context.semanticColor.labelAlternative,
                      leftIcon: Icons.terrain,
                      size: ContentBadgeSize.xsmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
