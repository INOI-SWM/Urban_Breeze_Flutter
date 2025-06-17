import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/badge/content_badge.dart';
import 'package:ridingmate/shared/design_system/widgets/thumbnail/thumbnail.dart';
import 'package:ridingmate/shared/design_system/widgets/toggle/favorite_toggle.dart';

class CardNormal extends StatefulWidget {
  const CardNormal({
    super.key,
    required this.thumbnailPath,
    required this.sourceType,
    required this.badgeText,
    required this.title,
    required this.createDate,
    required this.distance,
    required this.elevation,
  });

  final String thumbnailPath;
  final ThumbnailSourceType sourceType;
  final String badgeText;
  final String title;
  final String createDate;
  final String distance;
  final String elevation;

  @override
  State<CardNormal> createState() => _CardNormalState();
}

class _CardNormalState extends State<CardNormal> {
  bool _isFavorite = false;

  void _handleFavoriteChanged(bool value) {
    setState(() => _isFavorite = value);
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors semanticColors = context.semanticColor;

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Thumbnail(
                path: widget.thumbnailPath,
                ratio: ThumbnailRatio.r21_9,
                sourceType: widget.sourceType,
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
                        text: widget.badgeText,
                        size: ContentBadgeSize.medium,
                        type: ContentBadgeType.solid,
                        backgroundColor: semanticColors.fillNormal,
                        textColor: semanticColors.labelAlternative,
                        leftIcon: Icons.person,
                      ),
                      Row(
                        children: <Widget>[
                          FavoriteToggle(
                            isFavorite: _isFavorite,
                            onChanged: _handleFavoriteChanged,
                          ),
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title,
                  style: AppTextStyles.body2.normalBold.copyWith(
                    color: semanticColors.labelNormal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.createDate,
                  style: AppTextStyles.label2.medium.copyWith(
                    color: semanticColors.labelAlternative,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    ContentBadge(
                      text: widget.distance,
                      leftIcon: Icons.route,
                      size: ContentBadgeSize.xsmall,
                      type: ContentBadgeType.solid,
                      backgroundColor: semanticColors.fillNormal,
                      textColor: semanticColors.labelNeutral,
                    ),
                    const SizedBox(width: 4),
                    ContentBadge(
                      text: widget.elevation,
                      leftIcon: Icons.terrain,
                      size: ContentBadgeSize.xsmall,
                      type: ContentBadgeType.solid,
                      backgroundColor: semanticColors.fillNormal,
                      textColor: semanticColors.labelNeutral,
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
