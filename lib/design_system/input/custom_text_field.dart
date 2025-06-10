import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.headingText,
    this.description,
    this.disabled = false,
  });

  final String headingText;
  final String? description;
  final bool disabled;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode = FocusNode();

  bool get _isActive => _controller.text.isNotEmpty;
  bool get _hasFocus => _focusNode.hasFocus;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── headingText ──────────────────────────────────────────────
        Row(
          children: <Widget>[
            Text(
              widget.headingText,
              style: AppTextStyles.label1.normalBold.copyWith(
                color: colors.labelNeutral,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTextStyles.label1.normalMedium.copyWith(
                color: colors.statusNegative,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // ── 텍스트 입력 ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                widget.disabled
                    ? colors.interactionDisable
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  widget.disabled
                      ? colors.lineNormalAlternative
                      : (_hasFocus
                          ? colors.primaryNormal
                          : colors.lineNormalNeutral),
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !widget.disabled,
                  style: AppTextStyles.body1.normalRegular.copyWith(
                    color:
                        _isActive ? colors.labelNormal : colors.labelAssistive,
                  ),
                  cursorColor: colors.primaryNormal,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: '텍스트를 입력해 주세요.',
                    hintStyle: AppTextStyles.body1.normalRegular.copyWith(
                      color:
                          widget.disabled
                              ? colors.labelDisable
                              : colors.labelAssistive,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const Icon(Icons.star),
            ],
          ),
        ),
        // ── Description ────────────────────────────────────────────────
        if (widget.description != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            widget.description!,
            style: AppTextStyles.caption1.regular.copyWith(
              color: colors.labelAlternative,
            ),
          ),
        ],
      ],
    );
  }
}
