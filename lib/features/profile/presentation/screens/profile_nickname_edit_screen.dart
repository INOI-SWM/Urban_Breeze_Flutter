import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/profile/application/use_cases/update_nickname_use_case.dart';
import 'package:urban_breeze/features/profile/di/profile_providers.dart';
import 'package:urban_breeze/features/profile/domain/entities/profile.dart';
import 'package:urban_breeze/features/profile/presentation/mixins/profile_edit_button_mixin.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_app_bar.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_layout.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/text_field/custom_text_field.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class ProfileNicknameEditScreen extends ConsumerStatefulWidget {
  const ProfileNicknameEditScreen({super.key, required this.currentValue});

  final String currentValue;

  @override
  ConsumerState<ProfileNicknameEditScreen> createState() =>
      _ProfileNicknameEditScreenState();
}

class _ProfileNicknameEditScreenState
    extends ConsumerState<ProfileNicknameEditScreen>
    with ProfileEditButtonMixin<ProfileNicknameEditScreen>, ErrorDisplayMixin {
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
      'profile_nickname_saved',
      properties: <String, dynamic>{
        'old_value': widget.currentValue,
        'new_value': newValue,
        'value_length': newValue.length,
      },
    );

    final UpdateNicknameUseCase updateNicknameUseCase = ref.read(
      updateNicknameUseCaseProvider,
    );
    final AppResult<Profile> result = await updateNicknameUseCase.execute(
      newValue,
    );

    if (result.isSuccess) {
      if (mounted) {
        showSuccessMessage(context, '닉네임이 성공적으로 변경되었습니다');
        Navigator.of(context).pop(newValue);
      }
    } else {
      if (mounted) {
        showErrorMessage(
          context,
          '닉네임 변경에 실패했습니다: ${result.exceptionOrNull?.message}',
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
        title: '닉네임',
        isButtonEnabled: isButtonEnabled,
        onSave: onSave,
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
