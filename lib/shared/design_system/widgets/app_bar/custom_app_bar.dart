import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';

enum AppBarTitleSize { medium, large }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.centerTitle = true,
    this.titleTextSize = AppBarTitleSize.medium,
  });

  final Widget? leading;
  final String? title;
  final List<Widget>? actions;
  final bool centerTitle;
  final AppBarTitleSize titleTextSize;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    TextStyle getTitleStyle() {
      switch (titleTextSize) {
        case AppBarTitleSize.large:
          return AppTextStyles.heading2.bold.copyWith(
            color: colors.labelStrong,
          );
        case AppBarTitleSize.medium:
          return AppTextStyles.headline2.bold.copyWith(
            color: colors.labelStrong,
          );
      }
    }

    return SafeArea(
      child: SizedBox(
        height: kToolbarHeight,
        child: Stack(
          children: <Widget>[
            if (title != null)
              Align(
                alignment:
                    centerTitle ? Alignment.center : Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: centerTitle ? 0 : (leading != null ? 56 : 20),
                    right:
                        centerTitle
                            ? 0
                            : (actions != null && actions!.isNotEmpty
                                ? 56
                                : 16),
                  ),
                  child: Text(
                    title!,
                    style: getTitleStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

            if (leading != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: leading!,
                ),
              ),

            if (actions != null && actions!.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        actions!.asMap().entries.map((
                          MapEntry<int, Widget> entry,
                        ) {
                          final Widget action = entry.value;
                          final bool isLast = entry.key == actions!.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(right: isLast ? 0 : 8),
                            child: action,
                          );
                        }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
