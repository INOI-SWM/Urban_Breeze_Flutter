import 'package:flutter/material.dart';
import 'package:ridingmate/shared/design_system/widgets/modal/bottom_sheet_modal.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';
import 'package:ridingmate/shared/filter/models/filter_item.dart';
import 'package:ridingmate/shared/filter/widgets/filter_modal_content.dart';

class FilterModal {
  const FilterModal._();

  static Future<FilterData?> show({
    required BuildContext context,
    required List<FilterItem> filters,
    required FilterData initialData,
    required Function(FilterData) onApply,
    required VoidCallback onReset,
    bool showTabBar = true,
  }) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.9;

    return BottomSheetShow.show<FilterData>(
      context: context,
      title: '필터',
      content: FilterModalContent(
        filters: filters,
        initialData: initialData,
        onApply: onApply,
        onReset: onReset,
        showTabBar: showTabBar,
      ),
      constraints: BoxConstraints(maxHeight: maxHeight),
    );
  }
}
