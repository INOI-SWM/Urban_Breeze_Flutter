import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/effect/app_shadows.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

class RideButton extends StatelessWidget {
  const RideButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  static const double _radius = 32;
  static const EdgeInsets _padding = EdgeInsets.fromLTRB(12, 8, 20, 8);
  static const double _iconSize = 24;
  static const double _spaceBetweenIconAndText = 5;

  @override
  Widget build(BuildContext context) {
    final SemanticColors semanticColors = context.semanticColor;

    return Container(
      decoration: BoxDecoration(
        color: semanticColors.primaryNormal,
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: AppShadows.instance.emphasize,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(_radius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(_radius),
          child: Padding(
            padding: _padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.play_arrow_rounded,
                  size: _iconSize,
                  color: semanticColors.backgroundElevatedNormal,
                ),
                const SizedBox(width: _spaceBetweenIconAndText),
                Text(
                  '주행하기',
                  style: AppTextStyles.body1.normalBold.copyWith(
                    color: semanticColors.backgroundNormalNormal,
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
