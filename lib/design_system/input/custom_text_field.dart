import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/Icon/icon_size.dart';
import 'package:ridingmate/design_system/border/inset_border.dart';
import 'package:ridingmate/design_system/button/icon_button_solid.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.headingText,
    this.description,
    this.disabled = false,
    this.requiredBadge = false,
  });

  final String? headingText;
  final String? description;
  final bool disabled;
  final bool requiredBadge;

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

    final double innerBorderWidth = _hasFocus ? 2 : 1;
    final double containerPadding = 12 - innerBorderWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.headingText != null)
          Row(
            children: <Widget>[
              Text(
                widget.headingText!,
                style: AppTextStyles.label1.normalBold.copyWith(
                  color: colors.labelNeutral,
                ),
              ),
              const SizedBox(width: 4),
              if (widget.requiredBadge)
                Text(
                  '*',
                  style: AppTextStyles.label1.normalMedium.copyWith(
                    color: colors.statusNegative,
                  ),
                ),
            ],
          ),
        if (widget.headingText != null) const SizedBox(height: 8),
        InsetBorder(
          color:
              widget.disabled
                  ? colors.lineNormalAlternative
                  : (_hasFocus
                      ? colors.primaryNormal
                      : colors.lineNormalNeutral),
          width: innerBorderWidth,
          radius: 12,
          backgroundColor:
              widget.disabled ? colors.interactionDisable : Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(containerPadding),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: !widget.disabled,
                    style: AppTextStyles.body1.normalRegular.copyWith(
                      color:
                          _isActive
                              ? colors.labelNormal
                              : colors.labelAssistive,
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
                if (_hasFocus && _isActive)
                  IconButtonSolid(
                    icon: Icons.cancel,
                    onPressed: _controller.clear,
                    iconSize: IconSize.medium,
                    customButtonSize: 24,
                    backgroundColor: Colors.transparent,
                    iconColor: colors.labelAssistive,
                    shadow: null,
                  ),
              ],
            ),
          ),
        ),
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
