import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/input/search_field.dart';

class SearchNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  const SearchNavigationBar({
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
              // 뒤로가기 버튼
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  iconSize: 24,
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: colors.labelStrong,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 16),
              // 검색 필드
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
