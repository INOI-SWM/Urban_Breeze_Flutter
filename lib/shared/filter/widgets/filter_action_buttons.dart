import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_outlined.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_size.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_solid.dart';

class FilterActionButtons extends StatelessWidget {
  const FilterActionButtons({
    super.key,
    required this.onReset,
    required this.onApply,
  });

  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ButtonOutlined(
              text: '초기화',
              textColor: colors.labelNormal,
              borderColor: colors.lineNormalNeutral,
              size: ButtonSize.large,
              onPressed: onReset,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ButtonSolid(
              text: '적용하기',
              textColor: colors.staticWhite,
              backgroundColor: colors.primaryNormal,
              size: ButtonSize.large,
              onPressed: onApply,
            ),
          ),
        ],
      ),
    );
  }
}
