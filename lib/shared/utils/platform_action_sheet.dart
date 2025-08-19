import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';

class PlatformActionSheetOption {
  const PlatformActionSheetOption({
    required this.title,
    required this.onSelected,
    this.isDestructive = false,
  });

  final String title;
  final VoidCallback onSelected;
  final bool isDestructive;
}

Future<void> showPlatformActionSheet(
  BuildContext context, {
  String? title,
  String? message,
  required List<PlatformActionSheetOption> options,
  String cancelText = '취소',
  bool useRootNavigator = false,
}) async {
  final SemanticColors colors = context.semanticColor;
  final TargetPlatform platform = Theme.of(context).platform;
  if (platform == TargetPlatform.iOS) {
    await showCupertinoModalPopup<void>(
      context: context,
      useRootNavigator: useRootNavigator,
      builder:
          (BuildContext ctx) => CupertinoActionSheet(
            title:
                title != null
                    ? Text(
                      title,
                      style: AppTextStyles.label2.bold.copyWith(
                        color: colors.labelAlternative,
                      ),
                    )
                    : null,
            message:
                message != null
                    ? Text(
                      message,
                      style: AppTextStyles.label2.bold.copyWith(
                        color: colors.labelAlternative,
                      ),
                    )
                    : null,
            actions:
                options
                    .map(
                      (PlatformActionSheetOption opt) =>
                          CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              opt.onSelected();
                            },
                            isDestructiveAction: opt.isDestructive,
                            child: Text(
                              opt.title,
                              style: AppTextStyles.headline2.medium.copyWith(
                                color: colors.primaryNormal,
                              ),
                            ),
                          ),
                    )
                    .toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                cancelText,
                style: AppTextStyles.headline2.bold.copyWith(
                  color: colors.primaryNormal,
                ),
              ),
            ),
          ),
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext ctx) {
      return SafeArea(
        child: Wrap(
          children: <Widget>[
            for (final PlatformActionSheetOption opt in options)
              ListTile(
                title: Text(
                  opt.title,
                  style: TextStyle(
                    color:
                        opt.isDestructive
                            ? Theme.of(ctx).colorScheme.error
                            : null,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  opt.onSelected();
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(cancelText),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    },
  );
}
