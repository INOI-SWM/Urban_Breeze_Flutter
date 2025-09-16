import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/utils/profile_image_utils.dart';

class ProfileImageWidget extends StatelessWidget {
  const ProfileImageWidget({
    super.key,
    required this.imageUrl,
    this.size = 80,
    this.showBorder = true,
  });

  final String? imageUrl;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.backgroundElevatedNormal,
        border:
            showBorder
                ? Border.all(color: colors.lineNormalAlternative, width: 1)
                : null,
      ),
      child: ClipOval(
        child: ProfileImageUtils.buildProfileImage(
          context: context,
          imageUrl: imageUrl,
          size: size,
        ),
      ),
    );
  }
}
