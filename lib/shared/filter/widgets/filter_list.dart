import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';
import 'package:ridingmate/shared/filter/models/filter_item.dart';
import 'package:ridingmate/shared/filter/widgets/filter_widgets.dart';

class FilterList extends StatelessWidget {
  const FilterList({
    super.key,
    required this.filters,
    required this.currentData,
    required this.filterKeys,
    required this.scrollController,
    required this.onDataChanged,
  });

  final List<FilterItem> filters;
  final FilterData currentData;
  final Map<String, GlobalKey> filterKeys;
  final ScrollController scrollController;
  final Function(FilterData) onDataChanged;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ...filters.asMap().entries.map((MapEntry<int, FilterItem> entry) {
            final int index = entry.key;
            final FilterItem filter = entry.value;
            return Column(
              key: filterKeys[filter.title],
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FilterWidgets.buildFilterWidget(
                  filter: filter,
                  currentData: currentData,
                  onDataChanged: onDataChanged,
                ),
                if (index < filters.length - 1)
                  Container(
                    color: colors.backgroundNormalAlternative,
                    height: 8,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
