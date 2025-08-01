import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/modal/bottom_sheet_modal.dart';

enum WorkoutSortType {
  newest('최신순'),
  oldest('오래된 순'),
  distance('거리순');

  const WorkoutSortType(this.displayName);
  final String displayName;
}

class WorkoutSortModal {
  static const List<WorkoutSortType> sortOptions = <WorkoutSortType>[
    WorkoutSortType.newest,
    WorkoutSortType.oldest,
    WorkoutSortType.distance,
  ];

  static Future<WorkoutSortType?> show({
    required BuildContext context,
    required WorkoutSortType selectedOption,
    required Function(WorkoutSortType) onOptionSelected,
  }) {
    return BottomSheetShow.show<WorkoutSortType>(
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
                  sortOptions[i].displayName,
                  isSelected: sortOptions[i] == selectedOption,
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
