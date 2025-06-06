import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/Icon/icon_size.dart';
import 'package:ridingmate/design_system/button/icon_button_solid.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

class POISettingsGrid extends StatelessWidget {
  const POISettingsGrid({
    super.key,
    required this.settings,
    required this.selectedIndices,
    required this.onToggleSetting,
  });
  final List<Map<String, dynamic>> settings;
  final Set<int> selectedIndices;
  final Function(int) onToggleSetting;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final int rows = (settings.length / 4).ceil();
    final int maxRows = 2;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double itemWidth =
            (constraints.maxWidth - 30) / 4; // 30은 요소 간 간격(10 * 3)

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(rows > maxRows ? maxRows : rows, (
            int rowIndex,
          ) {
            return Padding(
              padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? 10 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List<Widget>.generate(4, (int colIndex) {
                  final int index = rowIndex * 4 + colIndex;
                  if (index >= settings.length) {
                    return SizedBox(width: itemWidth);
                  }

                  final bool isSelected = selectedIndices.contains(index);
                  final Map<String, dynamic> setting = settings[index];

                  return SizedBox(
                    width: itemWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButtonSolid(
                                icon: setting['icon'] as IconData,
                                onPressed: () => onToggleSetting(index),
                                iconSize: IconSize.xlarge,
                                backgroundColor:
                                    isSelected
                                        ? colors.primaryNormal
                                        : colors.fillNormal,
                                iconColor:
                                    isSelected
                                        ? colors.staticWhite
                                        : colors.labelDisable,
                                customButtonSize: 48,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                setting['label'] as String,
                                style: AppTextStyles.caption2.medium.copyWith(
                                  color:
                                      isSelected
                                          ? colors.primaryNormal
                                          : colors.labelDisable,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            );
          }),
        );
      },
    );
  }
}
