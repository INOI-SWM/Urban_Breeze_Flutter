import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/widgets/search_field/search_field.dart';
import 'package:ridingmate/shared/design_system/widgets/search_field/search_field_size.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({
    super.key,
    this.onBackPressed,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.searchController,
    this.searchFocusNode,
  });

  final VoidCallback? onBackPressed;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return SafeArea(
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 24,
                    color: colors.labelStrong,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SearchField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    onChanged: onSearchChanged,
                    onSubmitted: onSearchSubmitted,
                    size: SearchFieldSize.small,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
