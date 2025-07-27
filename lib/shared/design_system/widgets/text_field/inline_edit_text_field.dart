import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';

class InlineEditTextField extends StatefulWidget {
  const InlineEditTextField({
    super.key,
    required this.initialText,
    required this.onSaved,
    this.textStyle,
    this.maxLength = 60,
    this.autofocus = true,
  });

  final String initialText;
  final Function(String) onSaved;
  final TextStyle? textStyle;
  final int maxLength;
  final bool autofocus;

  @override
  State<InlineEditTextField> createState() => _InlineEditTextFieldState();
}

class _InlineEditTextFieldState extends State<InlineEditTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _onSave();
    }
  }

  void _onSave() {
    widget.onSaved(_controller.text.trim());
  }

  void _onClear() {
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: EditableText(
                controller: _controller,
                focusNode: _focusNode,
                style:
                    widget.textStyle ??
                    AppTextStyles.title3.bold.copyWith(
                      color: colors.labelStrong,
                    ),
                cursorColor: colors.primaryNormal,
                backgroundCursorColor: colors.primaryNormal.withValues(
                  alpha: 0.1,
                ),
                maxLines: 1,
                inputFormatters: <TextInputFormatter>[
                  LengthLimitingTextInputFormatter(widget.maxLength),
                ],
                onSubmitted: (_) => _onSave(),
              ),
            ),
            CustomIconButton(icon: Icons.close, onTap: _onClear),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${_controller.text.length}/${widget.maxLength}',
          style: AppTextStyles.caption2.regular.copyWith(
            color: colors.labelAlternative,
          ),
        ),
      ],
    );
  }
}
