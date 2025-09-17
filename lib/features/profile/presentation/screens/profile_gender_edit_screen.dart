import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/application/use_cases/update_gender_use_case.dart';
import 'package:urban_breeze/features/profile/di/profile_providers.dart';
import 'package:urban_breeze/features/profile/presentation/mixins/profile_edit_button_mixin.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_app_bar.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_layout.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';
import 'package:urban_breeze/shared/utils/error_message_mapper.dart';

class ProfileGenderEditScreen extends ConsumerStatefulWidget {
  const ProfileGenderEditScreen({super.key, required this.currentValue});

  final String currentValue;

  @override
  ConsumerState<ProfileGenderEditScreen> createState() =>
      _ProfileGenderEditScreenState();
}

class _ProfileGenderEditScreenState
    extends ConsumerState<ProfileGenderEditScreen>
    with ProfileEditButtonMixin<ProfileGenderEditScreen>, ErrorDisplayMixin {
  String? _selectedValue;

  @override
  String get currentValue => widget.currentValue;

  @override
  String? getCurrentInputValue() => _selectedValue;

  @override
  bool isValidInput(String? inputValue) => inputValue != null;

  @override
  Future<void> onSave() async {
    if (_selectedValue == null) return;

    AmplitudeAnalytics.logEvent(
      'profile_gender_saved',
      properties: <String, dynamic>{
        'old_value': widget.currentValue,
        'new_value': _selectedValue,
      },
    );

    // 한글을 API 형식으로 변환
    String apiGender = _selectedValue!;
    if (_selectedValue == '남성') {
      apiGender = 'MALE';
    } else if (_selectedValue == '여성') {
      apiGender = 'FEMALE';
    } else if (_selectedValue == '기타') {
      apiGender = 'OTHER';
    }

    final UpdateGenderUseCase updateGenderUseCase = ref.read(
      updateGenderUseCaseProvider,
    );
    final AppResult<User> result = await updateGenderUseCase.execute(apiGender);

    if (result.isSuccess) {
      if (mounted) {
        showSuccessMessage(context, '성별이 성공적으로 변경되었습니다');
        Navigator.of(context).pop(_selectedValue);
      }
    } else {
      if (mounted) {
        showErrorMessage(
          context,
          ErrorMessageMapper.getErrorMessage(result.exceptionOrNull!),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedValue =
        widget.currentValue.isNotEmpty ? widget.currentValue : null;
    checkButtonState();
  }

  void _onSelectionChanged(String gender) {
    setState(() {
      _selectedValue = gender;
    });
    checkButtonState();
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final List<String> genderOptions = <String>['남성', '여성', '기타'];

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: ProfileEditAppBar(
        title: '성별',
        isButtonEnabled: isButtonEnabled,
        onSave: onSave,
      ),
      body: ProfileEditLayout(
        title: '성별',
        description: '성별을 선택해주세요.',
        child: Column(
          children:
              genderOptions.map((String gender) {
                final bool isSelected = _selectedValue == gender;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => _onSelectionChanged(gender),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isSelected
                                      ? colors.primaryNormal
                                      : colors.lineNormalAlternative,
                              width: 2,
                            ),
                            color: colors.backgroundElevatedNormal,
                          ),
                          child:
                              isSelected
                                  ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colors.primaryNormal,
                                      ),
                                    ),
                                  )
                                  : null,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            gender,
                            style: AppTextStyles.body2.normalRegular.copyWith(
                              color: colors.labelNormal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
