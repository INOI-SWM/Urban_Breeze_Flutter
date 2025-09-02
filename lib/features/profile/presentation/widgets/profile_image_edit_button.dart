import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';

class ProfileImageEditButton extends StatelessWidget {
  const ProfileImageEditButton({
    super.key,
    required this.imageUrl,
    this.onPressed,
  });

  final String imageUrl;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: GestureDetector(
          onTap: onPressed,
          child: Stack(
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.backgroundElevatedNormal,
                  border: Border.all(
                    color: colors.lineNormalAlternative,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                  //TODO : 기본 이미지 설정, 로딩 시 로딩 표시
                ),
              ),

              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.primaryNormal,
                    border: Border.all(
                      color: colors.backgroundNormalNormal,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 12,
                    color: colors.staticWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
