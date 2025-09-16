import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/utils/profile_image_utils.dart';

class UserInfoInCard extends StatelessWidget {
  const UserInfoInCard({
    super.key,
    required this.userName,
    this.userProfileImage,
    this.avatarSize = 24.0,
    this.showBottomPadding = true,
  });

  final String? userName;
  final String? userProfileImage;
  final double avatarSize;
  final bool showBottomPadding;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Padding(
      padding: EdgeInsets.only(bottom: showBottomPadding ? 8 : 0),
      child: Row(
        children: <Widget>[
          // 사용자 프로필 이미지
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.lineNormalAlternative, width: 1),
              color: colors.backgroundNormalAlternative,
            ),
            child: ClipOval(
              child: ProfileImageUtils.buildProfileImage(
                context: context,
                imageUrl: userProfileImage,
                size: avatarSize,
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
}
