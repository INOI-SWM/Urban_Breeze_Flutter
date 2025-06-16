import 'package:flutter/material.dart';
import 'package:ridingmate/core/design/typography/app_text_style.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/widgets/input/base_search_field.dart';
import 'package:ridingmate/widgets/input/search_field_size.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.size = SearchFieldSize.medium,
    this.backgroundColor,
    this.boxShadow,
  });

  static const String _hintText = '검색어를 입력해주세요';

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final SearchFieldSize size;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

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

    return BaseSearchField(
      text: _controller.text,
      size: widget.size,
      backgroundColor: widget.backgroundColor ?? colors.fillNormal,
      boxShadow: widget.boxShadow,
      onClear: _clearText,
      hintText: SearchField._hintText,
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
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
    );
  }
}
