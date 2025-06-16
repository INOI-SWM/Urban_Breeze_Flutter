import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';

class FavoriteToggle extends StatelessWidget {
  const FavoriteToggle({
    super.key,
    required this.isFavorite,
    required this.onChanged,
  });

  final bool isFavorite;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final SemanticColors c = context.semanticColor;
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () => onChanged(!isFavorite),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 24,
          color: isFavorite ? c.primaryNormal : c.staticWhite,
        ),
      ),
    );
  }
}
