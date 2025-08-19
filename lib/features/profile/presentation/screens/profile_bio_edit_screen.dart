import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/profile/presentation/mixins/profile_edit_button_mixin.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_app_bar.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_layout.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';

class ProfileBioEditScreen extends StatefulWidget {
  const ProfileBioEditScreen({super.key, required this.currentValue});

  final String currentValue;

  @override
  State<ProfileBioEditScreen> createState() => _ProfileBioEditScreenState();
}

class _ProfileBioEditScreenState extends State<ProfileBioEditScreen>
    with ProfileEditButtonMixin<ProfileBioEditScreen> {
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
        title: '한 줄 소개',
        isButtonEnabled: isButtonEnabled,
        onSave: saveValue,
      ),
      body: ProfileEditLayout(
        title: '한 줄 소개',
        description: '나를 소개하는 한 줄을 작성해주세요.',
        child: Container(
          decoration: BoxDecoration(
            color: colors.backgroundElevatedNormal,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.lineNormalAlternative),
          ),
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _textController,
            autofocus: true,
            maxLines: 3,
            maxLength: 80,
            style: AppTextStyles.body1.normalRegular.copyWith(
              color: colors.labelStrong,
            ),
            decoration: InputDecoration(
              hintText: '한 줄 소개를 입력해주세요',
              hintStyle: AppTextStyles.body1.normalRegular.copyWith(
                color: colors.labelAssistive,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.only(bottom: 8),
              counterStyle: AppTextStyles.label2.medium.copyWith(
                color: colors.labelAlternative,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
