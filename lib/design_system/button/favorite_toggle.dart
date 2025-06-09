import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';

class FavoriteToggle extends StatefulWidget {
  const FavoriteToggle({
    super.key,
    this.initiallyFavorite = false,
    this.onChanged,
  });

  final bool initiallyFavorite;

  final ValueChanged<bool>? onChanged;

  @override
  State<FavoriteToggle> createState() => _FavoriteToggleState();
}

class _FavoriteToggleState extends State<FavoriteToggle> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initiallyFavorite;
  }

  void _toggle() {
    setState(() => _isFavorite = !_isFavorite);
    widget.onChanged?.call(_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors semanticColors = context.semanticColor;

    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: _toggle,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 24,
          color:
              _isFavorite
                  ? semanticColors.primaryNormal
                  : semanticColors.staticWhite,
        ),
      ),
    );
  }
}
