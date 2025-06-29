import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class ProfileBioEditScreen extends StatefulWidget {
  const ProfileBioEditScreen({super.key, required this.currentValue});

  final String currentValue;

  @override
  State<ProfileBioEditScreen> createState() => _ProfileBioEditScreenState();
}

class _ProfileBioEditScreenState extends State<ProfileBioEditScreen> {
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
      appBar: CustomAppBar(
        title: '한 줄 소개',
        leading: GestureDetector(
          child: const SizedBox(
            width: 24,
            height: 24,
            child: Icon(Icons.arrow_back_ios_new, size: 24),
          ),
          onTap: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: _isButtonEnabled ? _saveValue : null,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '완료',
                    style: AppTextStyles.label1.normalBold.copyWith(
                      color:
                          _isButtonEnabled
                              ? colors.primaryNormal
                              : colors.labelDisable,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '한 줄 소개',
              style: AppTextStyles.headline1.bold.copyWith(
                color: colors.labelStrong,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '나를 소개하는 한 줄을 작성해주세요.',
              style: AppTextStyles.body2.normalRegular.copyWith(
                color: colors.labelNormal,
              ),
            ),

            const SizedBox(height: 24),

            Container(
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
          ],
        ),
      ),
    );
  }

  void _saveValue() {
    final String value = _textController.text.trim();

    if (value.isNotEmpty && value != widget.currentValue) {
      Navigator.of(context).pop(value);
    }
  }
}
