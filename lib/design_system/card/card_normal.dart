import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/badge/content_badge.dart';
import 'package:ridingmate/design_system/button/favorite_toggle.dart';
import 'package:ridingmate/design_system/thumbnail/thumbnail.dart';

class CardNormal extends StatelessWidget {
  const CardNormal({
    super.key,
    required this.thumbnailPath,
    required this.thumbnailSourceType,
    required this.badgeText,
  });

  final String thumbnailPath;
  final ThumbnailSourceType thumbnailSourceType;
  final String badgeText;

  @override
  Widget build(BuildContext context) {
    final SemanticColors semanticColors = context.semanticColor;

    return SizedBox(
      width: 353,
      child: Stack(
        children: <Widget>[
          Thumbnail(
            path: thumbnailPath,
            ratio: ThumbnailRatio.r21_9,
            sourceType: thumbnailSourceType,
            hasRadius: true,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 56,
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ContentBadge(
                    text: badgeText,
                    size: ContentBadgeSize.medium,
                    type: ContentBadgeType.solid,
                    backgroundColor: semanticColors.fillNormal,
                    textColor: semanticColors.labelAlternative,
                    leftIcon: Icons.person,
                  ),
                  Row(
                    children: <Widget>[
                      const FavoriteToggle(),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.more_horiz,
                        size: 24,
                        color: semanticColors.staticWhite,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
