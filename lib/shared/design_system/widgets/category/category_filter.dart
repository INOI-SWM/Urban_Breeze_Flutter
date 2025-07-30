import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/widgets/chip/chip_action.dart';

enum CategoryFilterSize { small, medium, large, xlarge }

enum CategoryFilterMode { normal, alternative }

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onCategorySelected,
    this.size = CategoryFilterSize.medium,
    this.mode = CategoryFilterMode.alternative,
    this.categoryIcons,
    this.categoryRightIcons,
  });

  final List<String> categories;
  final Set<String> selectedCategories;
  final void Function(String category) onCategorySelected;
  final CategoryFilterSize size;
  final CategoryFilterMode mode;
  final Map<String, IconData>? categoryIcons;
  final Map<String, IconData>? categoryRightIcons;

  double get _spacing {
    switch (size) {
      case CategoryFilterSize.small:
        return 4;
      case CategoryFilterSize.medium:
        return 6;
      case CategoryFilterSize.large:
        return 8;
      case CategoryFilterSize.xlarge:
        return 10;
    }
  }

  ChipActionSize get _chipSize {
    switch (size) {
      case CategoryFilterSize.small:
        return ChipActionSize.xsmall;
      case CategoryFilterSize.medium:
        return ChipActionSize.small;
      case CategoryFilterSize.large:
        return ChipActionSize.medium;
      case CategoryFilterSize.xlarge:
        return ChipActionSize.large;
    }
  }

  ChipActionType _getChipActionType(bool isSelected) {
    if (isSelected) {
      return mode == CategoryFilterMode.normal
          ? ChipActionType.solid
          : ChipActionType.outlined;
    }
    return ChipActionType.outlined;
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    Color getChipActionTextColor(bool isSelected) {
      if (isSelected) {
        return mode == CategoryFilterMode.normal
            ? colors.inverseLabel
            : colors.primaryNormal;
      }
      return colors.labelAlternative;
    }

    Color? getChipActionBorderColor(bool isSelected) {
      if (isSelected) {
        return mode == CategoryFilterMode.normal
            ? null
            : colors.primaryNormal.withValues(alpha: 0.43);
      }
      return colors.lineNormalNeutral;
    }

    Color? getChipActionBackgroundColor(bool isSelected) {
      if (isSelected) {
        return mode == CategoryFilterMode.normal
            ? colors.labelStrong
            : colors.primaryNormal.withValues(alpha: 0.05);
      }
      return null;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            categories.map((String category) {
              final bool isSelected = selectedCategories.contains(category);
              return Padding(
                padding: EdgeInsets.only(
                  right: category == categories.last ? 0 : _spacing,
                ),
                child: ChipAction(
                  key: ValueKey<String>(category),
                  text: category,
                  leftIcon: categoryIcons?[category],
                  rightIcon: categoryRightIcons?[category],
                  size: _chipSize,
                  type: _getChipActionType(isSelected),
                  textColor: getChipActionTextColor(isSelected),
                  borderColor: getChipActionBorderColor(isSelected),
                  backgroundColor: getChipActionBackgroundColor(isSelected),
                  onPressed: () => onCategorySelected(category),
                ),
              );
            }).toList(),
      ),
    );
  }
}
