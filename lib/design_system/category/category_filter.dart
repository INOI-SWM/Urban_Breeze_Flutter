import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/design_system/chip/chip_action.dart';

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
  });

  final List<String> categories;
  final Set<String> selectedCategories;
  final void Function(String category) onCategorySelected;
  final CategoryFilterSize size;
  final CategoryFilterMode mode;

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

  @override
  Widget build(BuildContext context) {
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
                  text: category,
                  size: _chipSize,
                  type:
                      isSelected
                          ? (mode == CategoryFilterMode.normal
                              ? ChipActionType.solid
                              : ChipActionType.outlined)
                          : ChipActionType.outlined,
                  textColor:
                      isSelected
                          ? (mode == CategoryFilterMode.normal
                              ? context.semanticColor.inverseLabel
                              : context.semanticColor.primaryNormal)
                          : context.semanticColor.labelAlternative,
                  borderColor:
                      isSelected
                          ? (mode == CategoryFilterMode.normal
                              ? null
                              : context.semanticColor.primaryNormal.withAlpha(
                                110,
                              ))
                          : context.semanticColor.lineNormalNeutral,
                  backgroundColor:
                      isSelected
                          ? (mode == CategoryFilterMode.normal
                              ? context.semanticColor.labelStrong
                              : context.semanticColor.primaryNormal.withAlpha(
                                13,
                              ))
                          : null,
                  onPressed: () => onCategorySelected(category),
                ),
              );
            }).toList(),
      ),
    );
  }
}
