import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridingmate/core/design/decorations/app_shadows.dart';
import 'package:ridingmate/core/design/typography/app_text_style.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';

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
                SizedBox(
                  width: _iconSize,
                  height: _iconSize,
                  child: SvgPicture.asset(
                    'assets/icons/svg/play.svg',
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      semanticColors.backgroundElevatedNormal,
                      BlendMode.srcIn,
                    ),
                  ),
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
