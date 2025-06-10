import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

enum SearchFieldPreviewSize { small, medium }

class SearchFieldPreview extends StatelessWidget {
  const SearchFieldPreview({
    super.key,
    this.text,
    this.size = SearchFieldPreviewSize.medium,
    this.backgroundColor,
    this.onClear,
    this.boxShadow,
  });

  static const String _hintText = '검색어를 입력해주세요';

  final String? text;
  final SearchFieldPreviewSize size;
  final Color? backgroundColor;
  final VoidCallback? onClear;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final double padding = size == SearchFieldPreviewSize.small ? 8 : 12;
    final bool hasText = text?.isNotEmpty ?? false;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.fillNormal,
        borderRadius: BorderRadius.circular(12),
        boxShadow: boxShadow,
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(Icons.search, size: 20, color: colors.labelAlternative),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasText ? text! : _hintText,
              style: AppTextStyles.body1.normalRegular.copyWith(
                color: hasText ? colors.labelNormal : colors.labelAssistive,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasText) ...<Widget>[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: onClear,
                child: SvgPicture.asset(
                  'assets/icons/svg/circle_close_fill.svg',
                  width: 22,
                  height: 22,
                  colorFilter: ColorFilter.mode(
                    colors.labelAssistive,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
