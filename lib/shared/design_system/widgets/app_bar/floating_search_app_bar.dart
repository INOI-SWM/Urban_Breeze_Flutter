import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/shared/design_system/tokens/decorations/app_shadows.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/search_field/search_field_preview.dart';
import 'package:urban_breeze/shared/design_system/widgets/search_field/search_field_size.dart';

class FloatingSearchAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FloatingSearchAppBar({
    super.key,
    this.searchText,
    required this.onSearchTap,
    required this.onCloseTap,
    required this.onClearTap,
    this.isSearchActive = false,
  });

  final String? searchText;
  final VoidCallback onSearchTap;
  final VoidCallback onCloseTap;
  final VoidCallback onClearTap;
  final bool isSearchActive;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return SafeArea(
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                child: GestureDetector(
                  onTap: onCloseTap,
                  child: const Icon(Icons.close, size: 24),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 4,
                  ),
                  child: GestureDetector(
                    onTap: onSearchTap,
                    child: SearchFieldPreview(
                      text: searchText,
                      size: SearchFieldSize.small,
                      backgroundColor: colors.backgroundNormalNormal,
                      boxShadow: AppShadows.instance.emphasize,
                      onClear: onClearTap,
                      textColor:
                          isSearchActive
                              ? colors.labelNormal
                              : colors.labelAssistive,
                      hintTextColor:
                          isSearchActive
                              ? colors.labelNormal
                              : colors.labelAssistive,
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
