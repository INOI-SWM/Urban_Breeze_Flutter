import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';

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
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // 헤더
          _buildHeader(colors),
          // 구분선
          Container(height: 1, color: colors.lineNormalAlternative),
          // 내용 영역
          Padding(padding: const EdgeInsets.all(20), child: content),
        ],
      ),
    );
  }

  Widget _buildHeader(SemanticColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Builder(
        builder:
            (BuildContext context) => SizedBox(
              height: 24,
              child: Stack(
                children: <Widget>[
                  // 제목 (가운데 정렬)
                  if (title != null)
                    Center(
                      child: Text(
                        title!,
                        style: AppTextStyles.heading2.bold.copyWith(
                          color: colors.labelNormal,
                        ),
                      ),
                    ),
                  // 닫기 버튼 (우측 정렬)
                  if (showCloseButton)
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: onClose ?? () => Navigator.of(context).pop(),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Icon(
                            Icons.close,
                            size: 24,
                            color: colors.labelNormal,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      builder: (BuildContext context) {
        return Container(
          color: Colors.transparent,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: IntrinsicHeight(
            child: BottomSheetModal(
              title: title,
              content: content,
              showCloseButton: showCloseButton,
              onClose: onClose,
              isDismissible: isDismissible,
              enableDrag: enableDrag,
            ),
          ),
        );
      },
    );
  }
}
