import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

class TopNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavigationBar({
    super.key,
    this.leading,
    this.title,
    this.actions,
    this.centerTitle = true,
  });

  final Widget? leading;
  final String? title;
  final List<Widget>? actions;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return SizedBox(
      height: kToolbarHeight,
      child: Stack(
        children: <Widget>[
          if (title != null)
            Align(
              alignment: centerTitle ? Alignment.center : Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(
                  left: centerTitle ? 0 : (leading != null ? 56 : 16),
                  right:
                      centerTitle
                          ? 0
                          : (actions != null && actions!.isNotEmpty ? 56 : 16),
                ),
                child: Text(
                  title!,
                  style: AppTextStyles.headline2.bold.copyWith(
                    color: colors.labelStrong,
                  ),
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
                child: leading,
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
                        if (action is Icon) {
                          return Padding(
                            padding: EdgeInsets.only(right: isLast ? 0 : 8),
                            child: action,
                          );
                        }
                        return action;
                      }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
