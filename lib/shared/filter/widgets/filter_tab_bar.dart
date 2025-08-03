import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/filter/models/filter_item.dart';

class FilterTabBar extends StatelessWidget {
  const FilterTabBar({
    super.key,
    required this.filters,
    required this.selectedTab,
    required this.scrollController,
    required this.onTabChanged,
  });

  final List<FilterItem> filters;
  final String selectedTab;
  final ScrollController scrollController;
  final Function(String) onTabChanged;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return SingleChildScrollView(
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
            filters.asMap().entries.map((MapEntry<int, FilterItem> entry) {
              final int index = entry.key;
              final FilterItem filter = entry.value;
              final bool isSelected = filter.title == selectedTab;

              return Padding(
                padding: EdgeInsets.only(
                  right: index < filters.length - 1 ? 24 : 0,
                ),
                child: GestureDetector(
                  onTap: () => onTabChanged(filter.title),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color:
                              isSelected
                                  ? colors.labelNormal
                                  : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      filter.title,
                      style: AppTextStyles.headline2.bold.copyWith(
                        color:
                            isSelected
                                ? colors.labelNormal
                                : colors.labelAssistive,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
