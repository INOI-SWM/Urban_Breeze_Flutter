import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.headingText,
    this.description,
  });

  final String headingText;
  final String? description;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode = FocusNode();

  bool get _isActive => _controller.text.isNotEmpty; // active = true 조건
  bool get _hasFocus => _focusNode.hasFocus; // 포커스 상태

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {})); // 값 변경 시 active 갱신
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _hasFocus
                      ? colors
                          .primaryNormal // focus = true
                      : colors.lineNormalNeutral, // focus = false
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: AppTextStyles.body1.normalRegular.copyWith(
                    color:
                        _isActive
                            ? colors
                                .labelNormal // active = true
                            : colors.labelAssistive, // active = false
                  ),
                  cursorColor: colors.primaryNormal,
                  decoration: InputDecoration(
                    isCollapsed: true, // 내부 패딩 제거
                    hintText: '텍스트를 입력해 주세요.',
                    hintStyle: AppTextStyles.body1.normalRegular.copyWith(
                      color: colors.labelAssistive,
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
