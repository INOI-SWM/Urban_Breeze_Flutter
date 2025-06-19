import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.iconPath,
  });

  final String text;
  final VoidCallback onPressed;
  final String iconPath;

  static const double _borderRadius = 12;
  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 12,
  );
  static const double _iconSize = 24;
  static const double _spaceBetweenIconAndText = 6;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        border: Border.all(color: colors.lineNormalNormal),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(_borderRadius),
          child: Padding(
            padding: _padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Google 로고는 색상 변경 없이 원본 사용
                SvgPicture.asset(iconPath, width: _iconSize, height: _iconSize),
                const SizedBox(width: _spaceBetweenIconAndText),
                Text(
                  text,
                  style: AppTextStyles.body1.normalBold.copyWith(
                    color: colors.labelNormal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
