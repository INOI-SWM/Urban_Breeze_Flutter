import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/widgets/info/info_item.dart';

class InfoItemsRow extends StatelessWidget {
  const InfoItemsRow({
    super.key,
    required this.items,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
  });

  final List<InfoItemData> items;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.semanticColor.backgroundNormalNormal,
      ),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children:
            items.map((InfoItemData item) {
              return Expanded(
                child: InfoItem(
                  label: item.label,
                  value: item.value,
                  alignment: item.alignment,
                  labelColor: item.labelColor,
                  valueColor: item.valueColor,
                ),
              );
            }).toList(),
      ),
    );
  }
}

class InfoItemData {
  const InfoItemData({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.center,
    this.labelColor,
    this.valueColor,
  });

  final String label;
  final String value;
  final CrossAxisAlignment alignment;
  final Color? labelColor;
  final Color? valueColor;
}
