import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/profile/presentation/widgets/profile_edit_app_bar.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/text_field/custom_text_field.dart';

class ProfileNicknameEditScreen extends StatefulWidget {
  const ProfileNicknameEditScreen({super.key, required this.currentValue});

  final String currentValue;

  @override
  State<ProfileNicknameEditScreen> createState() =>
      _ProfileNicknameEditScreenState();
}

class _ProfileNicknameEditScreenState extends State<ProfileNicknameEditScreen> {
  late TextEditingController _textController;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentValue);
    _textController.addListener(_onTextChanged);
    _checkButtonState();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _checkButtonState();
  }

  void _checkButtonState() {
    final String currentText = _textController.text.trim();
    final bool shouldEnable =
        currentText.isNotEmpty && currentText != widget.currentValue;

    if (_isButtonEnabled != shouldEnable) {
      setState(() {
        _isButtonEnabled = shouldEnable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: ProfileEditAppBar(
        title: '닉네임',
        isButtonEnabled: _isButtonEnabled,
        onSave: _saveValue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '닉네임',
              style: AppTextStyles.headline1.bold.copyWith(
                color: colors.labelStrong,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '다른 사용자들에게 보여질 닉네임을 입력해주세요.',
              style: AppTextStyles.body2.normalRegular.copyWith(
                color: colors.labelNormal,
              ),
            ),

            const SizedBox(height: 24),

            CustomTextField(
              controller: _textController,
              hintText: '닉네임을 입력해주세요',
              autofocus: true,
            ),
          ],
        ),
      ),
    );
  }

  void _saveValue() {
    final String value = _textController.text.trim();

    if (value.isNotEmpty && value != widget.currentValue) {
      Navigator.of(context).pop(value);
      //TODO : 닉네임 수정 api 호출
    }
  }
}
