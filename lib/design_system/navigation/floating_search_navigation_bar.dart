import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/effect/app_shadows.dart';
import 'package:ridingmate/design_system/input/search_field_preview.dart';

class FloatingSearchNavigationBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FloatingSearchNavigationBar({
    super.key,
    this.searchText,
    this.searchController,
    required this.onSearchTap,
    required this.onCloseTap,
    required this.onSearchTextChanged,
    required this.onSearchTextSubmitted,
  });

  final String? searchText;
  final TextEditingController? searchController;
  final VoidCallback onSearchTap;
  final VoidCallback onCloseTap;
  final ValueChanged<String> onSearchTextChanged;
  final ValueChanged<String> onSearchTextSubmitted;

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.backgroundNormalNormal,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: AppShadows.instance.emphasize,
                ),
                child: IconButton(
                  iconSize: 24,
                  onPressed: onCloseTap,
                  icon: Icon(Icons.close, color: colors.labelStrong),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: onSearchTap,
                    child: SearchFieldPreview(
                      text: searchText,
                      size: SearchFieldPreviewSize.small,
                      backgroundColor: colors.backgroundNormalNormal,
                      boxShadow: AppShadows.instance.emphasize,
                      onClear: onCloseTap,
                    ),
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
