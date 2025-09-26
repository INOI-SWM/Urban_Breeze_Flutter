import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/profile/presentation/mixins/profile_edit_button_mixin.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_app_bar.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_layout.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class ProfileBirthYearEditScreen extends ConsumerStatefulWidget {
  const ProfileBirthYearEditScreen({super.key, required this.currentValue});

  final String currentValue;

  @override
  ConsumerState<ProfileBirthYearEditScreen> createState() =>
      _ProfileBirthYearEditScreenState();
}

class _ProfileBirthYearEditScreenState
    extends ConsumerState<ProfileBirthYearEditScreen>
    with ProfileEditButtonMixin<ProfileBirthYearEditScreen>, ErrorDisplayMixin {
  String? _selectedValue;
  late final List<String> _yearOptions;

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
      'profile_birth_year_saved',
      properties: <String, dynamic>{
        'old_value': widget.currentValue,
        'new_value': _selectedValue,
      },
    );

    final AppResult<User> result = await ref
        .read(userSessionNotifierProvider.notifier)
        .updateBirth(_selectedValue!);

    if (result.isSuccess) {
      if (mounted) {
        showSuccessMessage(context, '출생년도가 성공적으로 변경되었습니다');
        Navigator.of(context).pop(_selectedValue);
      }
    } else {
      if (mounted) {
        showErrorMessage(
          context,
          '출생년도 변경에 실패했습니다: ${result.exceptionOrNull?.message}',
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedValue =
        widget.currentValue.isNotEmpty ? widget.currentValue : null;

    _yearOptions = _generateYearOptions();

    checkButtonState();
  }

  List<String> _generateYearOptions() {
    final int currentYear = DateTime.now().year;
    final List<String> yearOptions = <String>[];

    for (int year = currentYear; year >= 1950; year--) {
      yearOptions.add(year.toString());
    }

    return yearOptions;
  }

  void _onSelectionChanged(String year) {
    setState(() {
      _selectedValue = year;
    });
    checkButtonState();
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: ProfileEditAppBar(
        title: '출생년도',
        isButtonEnabled: isButtonEnabled,
        onSave: onSave,
      ),
      body: ProfileEditLayout(
        title: '출생년도',
        description: '출생연도를 선택해주세요.',
        child: Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.backgroundElevatedNormal,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.lineNormalAlternative),
            ),
            child: ListView.builder(
              itemCount: _yearOptions.length,
              itemBuilder: (BuildContext context, int index) {
                final String year = _yearOptions[index];
                final bool isSelected = _selectedValue == year;

                return GestureDetector(
                  onTap: () => _onSelectionChanged(year),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? colors.primaryNormal.withValues(alpha: 0.1)
                              : null,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '$year년',
                            style: AppTextStyles.body1.normalMedium.copyWith(
                              color:
                                  isSelected
                                      ? colors.primaryNormal
                                      : colors.labelStrong,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: colors.primaryNormal,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
