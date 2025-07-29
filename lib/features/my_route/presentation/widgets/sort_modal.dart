import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/modal/bottom_sheet_modal.dart';

class SortModal {
  static const List<String> sortOptions = <String>[
    '최근 생성 순',
    '생성 오래된 순',
    '가까운 순',
    '거리 긴 순',
    '거리 짧은 순',
  ];

  static Future<String?> show({
    required BuildContext context,
    required String selectedOption,
    required Function(String) onOptionSelected,
  }) {
    return BottomSheetShow.show<String>(
      context: context,
      title: '정렬',
      content: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(sortOptions.length, (int i) {
            return Column(
              children: <Widget>[
                _buildSortOption(
                  context,
                  sortOptions[i],
                  isSelected: sortOptions[i] == selectedOption,
                  hasIcon: sortOptions[i] == selectedOption,
                  onTap: () {
                    Navigator.of(context).pop();
                    onOptionSelected(sortOptions[i]);
                  },
                ),
                if (i < sortOptions.length - 1) const SizedBox(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }

  static Widget _buildSortOption(
    BuildContext context,
    String title, {
    required bool isSelected,
    bool hasIcon = false,
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
          if (hasIcon) Icon(Icons.check, color: colors.primaryNormal, size: 24),
        ],
      ),
    );
  }
}
