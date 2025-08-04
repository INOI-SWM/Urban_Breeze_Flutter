import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/modal/bottom_sheet_modal.dart';

class SortModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required List<T> options,
    required T selectedOption,
    required Function(T) onOptionSelected,
    required String Function(T) getDisplayText,
    String title = '정렬',
  }) {
    return BottomSheetShow.show<T>(
      context: context,
      title: title,
      content: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(options.length, (int i) {
              return Column(
                children: <Widget>[
                  _buildSortOption(
                    context,
                    getDisplayText(options[i]),
                    isSelected: options[i] == selectedOption,
                    onTap: () {
                      Navigator.of(context).pop();
                      onOptionSelected(options[i]);
                    },
                  ),
                  if (i < options.length - 1) const SizedBox(height: 20),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  static Widget _buildSortOption(
    BuildContext context,
    String title, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final SemanticColors colors = context.semanticColor;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.heading2.bold.copyWith(
                color: isSelected ? colors.labelNormal : colors.labelAssistive,
              ),
            ),
          ),
          if (isSelected)
            Icon(Icons.check, color: colors.primaryNormal, size: 24),
        ],
      ),
    );
  }
}
