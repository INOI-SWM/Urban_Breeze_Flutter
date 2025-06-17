import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';

class RoutePinMarker extends StatelessWidget {
  const RoutePinMarker({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: context.semanticColor.accentBackgroundRedOrange,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: AppTextStyles.caption2.regular.copyWith(
            color: context.semanticColor.staticWhite,
          ),
        ),
      ),
    );
  }
}
