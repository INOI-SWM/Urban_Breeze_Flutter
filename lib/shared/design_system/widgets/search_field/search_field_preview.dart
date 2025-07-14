import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/decorations/app_shadows.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/widgets/search_field/base_search_field.dart';
import 'package:ridingmate/shared/design_system/widgets/search_field/search_field_size.dart';

class SearchFieldPreview extends StatelessWidget {
  const SearchFieldPreview({
    super.key,
    this.text,
    this.size = SearchFieldSize.medium,
    this.backgroundColor,
    this.onClear,
    this.boxShadow,
    this.textColor,
    this.hintTextColor,
  });

  final String? text;
  final SearchFieldSize size;
  final Color? backgroundColor;
  final VoidCallback? onClear;
  final List<BoxShadow>? boxShadow;
  final Color? textColor;
  final Color? hintTextColor;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return BaseSearchField(
      text: text,
      size: size,
      backgroundColor: backgroundColor ?? colors.fillNormal,
      boxShadow: boxShadow ?? AppShadows.instance.emphasize,
      onClear: onClear,
      textColor: textColor,
      hintTextColor: hintTextColor,
    );
  }
}
