import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/design_system/chip/chip_action.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onCategorySelected,
    this.spacing = 10,
  });

  final List<String> categories;
  final Set<String> selectedCategories;
  final void Function(String category) onCategorySelected;
  final double spacing;

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
                  right: category == categories.last ? 0 : spacing,
                ),
                child: ChipAction(
                  text: category,
                  size: ChipActionSize.medium,
                  type: ChipActionType.outlined,
                  textColor:
                      isSelected
                          ? context.semanticColor.primaryNormal
                          : context.semanticColor.labelNormal,
                  borderColor:
                      isSelected
                          ? context.semanticColor.primaryNormal.withOpacity(
                            0.43,
                          )
                          : context.semanticColor.lineNormalNeutral,
                  backgroundColor:
                      isSelected
                          ? context.semanticColor.primaryNormal.withOpacity(
                            0.05,
                          )
                          : null,
                  onPressed: () => onCategorySelected(category),
                ),
              );
            }).toList(),
      ),
    );
  }
}
