import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
      decoration: BoxDecoration(
        color: colors.backgroundElevatedAlternative,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(children: _withDividers(children, colors)),
    );
  }

  List<Widget> _withDividers(List<Widget> items, SemanticColors colors) {
    final List<Widget> result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(Divider(color: colors.lineNormalNormal, height: 24));
      }
    }
    return result;
  }
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.title,
    this.onPressed,
    this.rightWidget,
    this.showArrow = true,
    this.textColor,
  });

  final String title;
  final VoidCallback? onPressed;
  final Widget? rightWidget;
  final bool showArrow;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    Widget? trailing;
    if (rightWidget != null) {
      trailing = rightWidget;
    } else if (showArrow) {
      trailing = Icon(
        Icons.arrow_forward_ios,
        size: 24,
        color: colors.labelAssistive,
      );
    }

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: AppTextStyles.body1.normalMedium.copyWith(
              color: textColor ?? colors.labelNormal,
            ),
          ),
          if (trailing != null)
            Padding(padding: const EdgeInsets.only(right: 6), child: trailing),
        ],
      ),
    );
  }
}
