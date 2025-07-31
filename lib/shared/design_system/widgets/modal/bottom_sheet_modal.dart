import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';

class BottomSheetModal extends StatelessWidget {
  const BottomSheetModal({
    super.key,
    this.title,
    required this.content,
    this.showCloseButton = true,
    this.onClose,
    this.isDismissible = true,
    this.enableDrag = true,
  });

  final String? title;
  final Widget content;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final bool isDismissible;
  final bool enableDrag;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundNormalNormal,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 헤더 - CustomAppBar 사용
            CustomAppBar(
              title: title,
              actions:
                  showCloseButton
                      ? <Widget>[
                        CustomIconButton(
                          icon: Icons.close,
                          onTap: onClose ?? () => Navigator.of(context).pop(),
                        ),
                      ]
                      : null,
              centerTitle: true,
              titleTextSize: AppBarTitleSize.medium,
              height: 64,
            ),
            // 내용 영역
            content,
          ],
        ),
      ),
    );
  }
}

class BottomSheetShow {
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    bool showCloseButton = true,
    VoidCallback? onClose,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (BuildContext context) {
        return BottomSheetModal(
          title: title,
          content: content,
          showCloseButton: showCloseButton,
          onClose: onClose,
          isDismissible: isDismissible,
          enableDrag: enableDrag,
        );
      },
    );
  }
}
