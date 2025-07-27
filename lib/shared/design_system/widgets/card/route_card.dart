import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/badge/content_badge.dart';
import 'package:ridingmate/shared/design_system/widgets/thumbnail/thumbnail.dart';

class RouteCard extends StatelessWidget {
  const RouteCard({
    super.key,
    required this.thumbnailPath,
    required this.sourceType,
    required this.userProfileImage,
    required this.userName,
    required this.routeTitle,
    required this.date,
    this.caption,
    required this.distance,
    required this.elevation,
    this.onTap,
  });

  final String thumbnailPath;
  final ThumbnailSourceType sourceType;
  final String userProfileImage;
  final String userName;
  final String routeTitle;
  final String date;
  final String? caption;
  final String distance;
  final String elevation;
  final VoidCallback? onTap;

  static const double _thumbnailWidth = 176.0;
  static const double _thumbnailHeight = 124.0;
  static const double _borderRadius = 12.0;
  static const double _avatarSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.backgroundNormalNormal,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(color: colors.lineNormalAlternative, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_borderRadius),
                bottomLeft: Radius.circular(_borderRadius),
              ),
              child: SizedBox(
                width: _thumbnailWidth,
                height: _thumbnailHeight,
                child: Thumbnail(
                  path: thumbnailPath,
                  ratio: ThumbnailRatio.r3_2,
                  sourceType: sourceType,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildUserInfo(colors),
                  const SizedBox(height: 8),
                  // 경로 제목
                  Text(
                    routeTitle,
                    style: AppTextStyles.body2.normalBold.copyWith(
                      color: colors.labelNormal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 날짜
                  Text(
                    date,
                    style: AppTextStyles.label2.medium.copyWith(
                      color: colors.labelAssistive,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 하단 영역 (배지들)
                  _buildBadges(colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(SemanticColors colors) {
    return Row(
      children: <Widget>[
        // 사용자 프로필 이미지
        Container(
          width: _avatarSize,
          height: _avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.lineNormalAlternative, width: 1),
          ),
          child: ClipOval(
            child: Image.network(
              userProfileImage,
              fit: BoxFit.cover,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return Container(
                  color: colors.fillNormal,
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: colors.labelAssistive,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 사용자 이름
        Expanded(
          child: Text(
            userName,
            style: AppTextStyles.label2.medium.copyWith(
              color: colors.labelAssistive,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(SemanticColors colors) {
    return Row(
      children: <Widget>[
        ContentBadge(
          text: distance,
          leftIcon: Icons.route,
          size: ContentBadgeSize.xsmall,
          type: ContentBadgeType.solid,
          backgroundColor: colors.fillNormal,
          textColor: colors.labelAssistive,
        ),
        const SizedBox(width: 6),
        ContentBadge(
          text: elevation,
          leftIcon: Icons.trending_up,
          size: ContentBadgeSize.xsmall,
          type: ContentBadgeType.solid,
          backgroundColor: colors.fillNormal,
          textColor: colors.labelAssistive,
        ),
      ],
    );
  }
}
