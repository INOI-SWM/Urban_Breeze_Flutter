import 'package:flutter/material.dart';
import 'package:ridingmate/core/design/decorations/app_shadows.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/widgets/input/base_search_field.dart';
import 'package:ridingmate/widgets/input/search_field_size.dart';

class SearchFieldPreview extends StatelessWidget {
  const SearchFieldPreview({
    super.key,
    this.text,
    this.size = SearchFieldSize.medium,
    this.backgroundColor,
    this.onClear,
    this.boxShadow,
  });

  final String? text;
  final SearchFieldSize size;
  final Color? backgroundColor;
  final VoidCallback? onClear;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return BaseSearchField(
      text: text,
      size: size,
      backgroundColor: backgroundColor ?? colors.fillNormal,
      boxShadow: boxShadow ?? AppShadows.instance.emphasize,
      onClear: onClear,
    );
  }
}
