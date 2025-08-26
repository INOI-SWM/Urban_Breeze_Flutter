import 'package:flutter/material.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/profile/presentation/mixins/profile_edit_button_mixin.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_app_bar.dart';
import 'package:urban_breeze/features/profile/presentation/widgets/profile_edit_layout.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';

class ProfileGenderEditScreen extends StatefulWidget {
  const ProfileGenderEditScreen({super.key, required this.currentValue});

  final String currentValue;

  @override
  State<ProfileGenderEditScreen> createState() =>
      _ProfileGenderEditScreenState();
}

class _ProfileGenderEditScreenState extends State<ProfileGenderEditScreen>
    with ProfileEditButtonMixin<ProfileGenderEditScreen> {
  String? _selectedValue;

  @override
  String get currentValue => widget.currentValue;

  @override
  String? getCurrentInputValue() => _selectedValue;

  @override
  bool isValidInput(String? inputValue) => inputValue != null;

  @override
  void onSave() {
    AmplitudeAnalytics.logEvent(
      'profile_gender_saved',
      properties: <String, dynamic>{
        'old_value': widget.currentValue,
        'new_value': _selectedValue,
      },
    );

    Navigator.of(context).pop(_selectedValue);
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
        onSave: saveValue,
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
