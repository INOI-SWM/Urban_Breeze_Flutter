import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/effect/app_shadows.dart';
import 'package:ridingmate/design_system/input/search_field.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

class FloatingSearchBar extends StatelessWidget implements PreferredSizeWidget {
  const FloatingSearchBar({
    super.key,
    required this.onSearchTap,
    this.onCloseTap,
    this.searchText,
    this.onSearchTextChanged,
    this.onSearchTextSubmitted,
  });

  final VoidCallback onSearchTap;
  final VoidCallback? onCloseTap;
  final String? searchText;
  final ValueChanged<String>? onSearchTextChanged;
  final ValueChanged<String>? onSearchTextSubmitted;

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
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.backgroundNormalNormal,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppShadows.instance.emphasize,
                    ),
                    child:
                        searchText != null
                            ? SearchField(
                              controller: TextEditingController(
                                text: searchText,
                              ),
                              onChanged: onSearchTextChanged,
                              onSubmitted: onSearchTextSubmitted,
                              size: SearchFieldSize.small,
                              backgroundColor: colors.backgroundNormalNormal,
                            )
                            : GestureDetector(
                              onTap: onSearchTap,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      child: Icon(
                                        Icons.search,
                                        size: 20,
                                        color: colors.labelAlternative,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '검색어를 입력해주세요',
                                      style: AppTextStyles.body1.normalRegular
                                          .copyWith(
                                            color: colors.labelAssistive,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
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
