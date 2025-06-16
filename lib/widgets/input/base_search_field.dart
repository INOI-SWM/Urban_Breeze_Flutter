import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridingmate/core/design/typography/app_text_style.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/widgets/input/search_field_size.dart';

class BaseSearchField extends StatelessWidget {
  const BaseSearchField({
    super.key,
    required this.text,
    required this.size,
    required this.backgroundColor,
    this.boxShadow,
    this.onClear,
    this.hintText = '검색어를 입력해주세요',
    this.child,
  });

  final String? text;
  final SearchFieldSize size;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onClear;
  final String hintText;
  final Widget? child;

  double get _padding => size == SearchFieldSize.small ? 8 : 12;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final bool hasText = text?.isNotEmpty ?? false;

    return Container(
      padding: EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: backgroundColor,
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
            child:
                child ??
                Text(
                  hasText ? text! : hintText,
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
