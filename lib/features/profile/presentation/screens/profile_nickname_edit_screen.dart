import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/profile/presentation/mixins/profile_edit_button_mixin.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_app_bar.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_layout.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/text_field/custom_text_field.dart';

class ProfileNicknameEditScreen extends StatefulWidget {
  const ProfileNicknameEditScreen({super.key, required this.currentValue});

  final String currentValue;

  @override
  State<ProfileNicknameEditScreen> createState() =>
      _ProfileNicknameEditScreenState();
}

class _ProfileNicknameEditScreenState extends State<ProfileNicknameEditScreen>
    with ProfileEditButtonMixin<ProfileNicknameEditScreen> {
  late TextEditingController _textController;

  @override
  String get currentValue => widget.currentValue;

  @override
  String? getCurrentInputValue() => _textController.text.trim();

  @override
  bool isValidInput(String? inputValue) =>
      inputValue != null && inputValue.isNotEmpty;

  @override
  void onSave() {
    Navigator.of(context).pop(getCurrentInputValue());
    //TODO : 닉네임 수정 api 호출
  }

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentValue);
    _textController.addListener(_onTextChanged);
    checkButtonState();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    checkButtonState();
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: ProfileEditAppBar(
        title: '닉네임',
        isButtonEnabled: isButtonEnabled,
        onSave: saveValue,
      ),
      body: ProfileEditLayout(
        title: '닉네임',
        description: '다른 사용자들에게 보여질 닉네임을 입력해주세요.',
        child: CustomTextField(
          controller: _textController,
          hintText: '닉네임을 입력해주세요',
          autofocus: true,
        ),
      ),
    );
  }
}
