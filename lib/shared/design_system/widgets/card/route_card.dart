import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/badge/content_badge.dart';
import 'package:ridingmate/shared/design_system/widgets/thumbnail/thumbnail.dart';

enum RouteCardType {
  myRoute, // 나의 경로: 유저 프로필, 제목, 날짜, 뱃지
  recommendedCourse, // 추천 코스: 지역, 제목, 뱃지
}

class RouteCard extends StatelessWidget {
  const RouteCard({
    super.key,
    required this.thumbnailPath,
    required this.sourceType,
    required this.routeTitle,
    required this.distance,
    required this.elevation,
    required this.cardType,
    this.userProfileImage,
    this.userName,
    this.date,
    this.region,
    this.difficulty,
    this.scenery,
    this.caption,
    this.onTap,
  });

  final String thumbnailPath;
  final ThumbnailSourceType sourceType;
  final String routeTitle;
  final String distance;
  final String elevation;
  final RouteCardType cardType;
  final String? userProfileImage;
  final String? userName;
  final String? date;
  final String? region;
  final String? difficulty;
  final String? scenery;
  final String? caption;
  final VoidCallback? onTap;

  static const double _thumbnailWidth = 180.0;
  static const double _thumbnailHeight = 120.0;
  static const double _thumbnailBorderRadius = 12.0;
  static const double _avatarSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_thumbnailBorderRadius),
              border: Border.all(color: colors.lineNormalAlternative, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_thumbnailBorderRadius),
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
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 상단 정보 (유저 프로필 or 지역)
                _buildTopInfo(colors),
                // 경로 제목
                Text(
                  routeTitle,
                  style: AppTextStyles.body2.normalBold.copyWith(
                    color: colors.labelNormal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (cardType == RouteCardType.myRoute &&
                    date != null) ...<Widget>[
                  const SizedBox(height: 4),
                  // 날짜 (나의 경로에서만 표시)
                  Text(
                    date!,
                    style: AppTextStyles.label2.medium.copyWith(
                      color: colors.labelAlternative,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // 하단 영역 (배지들)
                _buildBadges(colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopInfo(SemanticColors colors) {
    switch (cardType) {
      case RouteCardType.myRoute:
        return _buildUserInfo(colors);
      case RouteCardType.recommendedCourse:
        return _buildRegionInfo(colors);
    }
  }

  Widget _buildUserInfo(SemanticColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          // 사용자 프로필 이미지
          Container(
            width: _avatarSize,
            height: _avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.lineNormalAlternative, width: 1),
              color: colors.backgroundNormalAlternative,
            ),
            child: ClipOval(
              child:
                  (userProfileImage?.isNotEmpty == true)
                      ? Image.network(
                        userProfileImage!,
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
                              color: colors.backgroundNormalNormal,
                            ),
                          );
                        },
                      )
                      : Container(
                        color: colors.fillNormal,
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: colors.backgroundNormalNormal,
                        ),
                      ),
            ),
          ),
          const SizedBox(width: 4),
          // 사용자 이름
          Expanded(
            child: Text(
              userName ?? '',
              style: AppTextStyles.label2.medium.copyWith(
                color: colors.labelAlternative,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionInfo(SemanticColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              region ?? '',
              style: AppTextStyles.label2.medium.copyWith(
                color: colors.labelAlternative,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadges(SemanticColors colors) {
    final List<Widget> badges = <Widget>[
      ContentBadge(
        text: distance,
        leftIcon: Icons.route,
        size: ContentBadgeSize.xsmall,
        type: ContentBadgeType.solid,
        backgroundColor: colors.fillNormal,
        textColor: colors.labelAlternative,
      ),
      ContentBadge(
        text: elevation,
        leftIcon: Icons.trending_up,
        size: ContentBadgeSize.xsmall,
        type: ContentBadgeType.solid,
        backgroundColor: colors.fillNormal,
        textColor: colors.labelAlternative,
      ),
    ];

    if (cardType == RouteCardType.recommendedCourse) {
      if (difficulty != null) {
        badges.add(
          ContentBadge(
            text: difficulty!,
            size: ContentBadgeSize.xsmall,
            type: ContentBadgeType.solid,
            backgroundColor: colors.fillNormal,
            textColor: colors.labelAlternative,
          ),
        );
      }

      if (scenery != null) {
        badges.add(
          ContentBadge(
            text: scenery!,
            size: ContentBadgeSize.xsmall,
            type: ContentBadgeType.solid,
            backgroundColor: colors.fillNormal,
            textColor: colors.labelAlternative,
          ),
        );
      }
    }

    return Wrap(spacing: 6, runSpacing: 8, children: badges);
  }
}
