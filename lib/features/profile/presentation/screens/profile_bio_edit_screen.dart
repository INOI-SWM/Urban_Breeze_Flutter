import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/profile/application/use_cases/update_introduce_use_case.dart';
import 'package:urban_breeze/features/profile/di/profile_providers.dart';
import 'package:urban_breeze/features/profile/domain/entities/profile.dart';
import 'package:urban_breeze/features/profile/presentation/mixins/profile_edit_button_mixin.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_app_bar.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_layout.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class ProfileBioEditScreen extends ConsumerStatefulWidget {
  const ProfileBioEditScreen({super.key, required this.currentValue});

  final String currentValue;

  @override
  ConsumerState<ProfileBioEditScreen> createState() =>
      _ProfileBioEditScreenState();
}

class _ProfileBioEditScreenState extends ConsumerState<ProfileBioEditScreen>
    with ProfileEditButtonMixin<ProfileBioEditScreen>, ErrorDisplayMixin {
  late TextEditingController _textController;

  @override
  String get currentValue => widget.currentValue;

  @override
  String? getCurrentInputValue() => _textController.text.trim();

  @override
  bool isValidInput(String? inputValue) =>
      inputValue != null && inputValue.isNotEmpty;

  @override
  Future<void> onSave() async {
    final String? newValue = getCurrentInputValue();
    if (newValue == null || newValue.isEmpty) return;

    AmplitudeAnalytics.logEvent(
      'profile_bio_saved',
      properties: <String, dynamic>{
        'old_value': widget.currentValue,
        'new_value': newValue,
        'value_length': newValue.length,
      },
    );

    final UpdateIntroduceUseCase updateIntroduceUseCase = ref.read(
      updateIntroduceUseCaseProvider,
    );
    final AppResult<Profile> result = await updateIntroduceUseCase.execute(
      newValue,
    );

    if (result.isSuccess) {
      if (mounted) {
        showSuccessMessage(context, '자기소개가 성공적으로 변경되었습니다');
        Navigator.of(context).pop(newValue);
      }
    } else {
      if (mounted) {
        showErrorMessage(
          context,
          '자기소개 변경에 실패했습니다: ${result.exceptionOrNull?.message}',
        );
      }
    }
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
        onSave: onSave,
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
