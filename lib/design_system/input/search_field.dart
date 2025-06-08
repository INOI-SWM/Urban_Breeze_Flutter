import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

enum SearchFieldSize { small, medium }

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.size = SearchFieldSize.medium,
  });

  static const String _hintText = '검색어를 입력해주세요';

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final SearchFieldSize size;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_updateHasText);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateHasText);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (oldWidget.controller == null) {
        _controller.removeListener(_updateHasText);
        _controller.dispose();
      }

      _controller = widget.controller ?? TextEditingController();
      _hasText = _controller.text.isNotEmpty;
      _controller.addListener(_updateHasText);
    }
  }

  double get _padding => widget.size == SearchFieldSize.small ? 8 : 12;

  void _updateHasText() {
    final bool newHasText = _controller.text.isNotEmpty;
    if (_hasText != newHasText) {
      setState(() {
        _hasText = newHasText;
      });
    }
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Container(
      padding: EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: colors.fillNormal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Icon(Icons.search, size: 20, color: colors.labelAlternative),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: widget.focusNode,
              onChanged: (String value) {
                widget.onChanged?.call(value);
              },
              onSubmitted: widget.onSubmitted,
              style: AppTextStyles.body1.normalRegular.copyWith(
                color: colors.labelNormal,
              ),
              decoration: InputDecoration(
                hintText: SearchField._hintText,
                hintStyle: AppTextStyles.body1.normalRegular.copyWith(
                  color: colors.labelAssistive,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (_hasText) ...<Widget>[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: GestureDetector(
                onTap: _clearText,
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
