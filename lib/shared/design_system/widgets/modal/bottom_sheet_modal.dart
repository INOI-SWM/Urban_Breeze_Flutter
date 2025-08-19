import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class BottomSheetModal extends StatelessWidget {
  const BottomSheetModal({
    super.key,
    this.appBar,
    required this.content,
    this.isDismissible = true,
    this.enableDrag = true,
  });

  final CustomAppBar? appBar;
  final Widget content;
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
            appBar ?? const CustomAppBar(title: ''),
            // 내용 영역
            Flexible(child: content),
          ],
        ),
      ),
    );
  }
}

class BottomSheetShow {
  static Future<T?> show<T>({
    required BuildContext context,
    CustomAppBar? appBar,
    required Widget content,
    bool isDismissible = true,
    bool enableDrag = true,
    BoxConstraints? constraints,
    bool useBarrier = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      constraints: constraints,
      barrierColor: useBarrier ? Colors.black54 : Colors.transparent,
      builder: (BuildContext context) {
        return BottomSheetModal(
          appBar: appBar,
          content: content,
          isDismissible: isDismissible,
          enableDrag: enableDrag,
        );
      },
    );
  }
}
