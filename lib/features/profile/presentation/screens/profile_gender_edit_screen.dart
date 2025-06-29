import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/profile/presentation/widgets/profile_edit_app_bar.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';

class ProfileGenderEditScreen extends StatefulWidget {
  const ProfileGenderEditScreen({super.key, required this.currentValue});

  final String currentValue;

  @override
  State<ProfileGenderEditScreen> createState() =>
      _ProfileGenderEditScreenState();
}

class _ProfileGenderEditScreenState extends State<ProfileGenderEditScreen> {
  String? _selectedValue;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedValue =
        widget.currentValue.isNotEmpty ? widget.currentValue : null;
    _checkButtonState();
  }

  void _checkButtonState() {
    final bool shouldEnable = _selectedValue != widget.currentValue;

    if (_isButtonEnabled != shouldEnable) {
      setState(() {
        _isButtonEnabled = shouldEnable;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final List<String> genderOptions = <String>['남성', '여성', '기타'];

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: ProfileEditAppBar(
        title: '성별',
        isButtonEnabled: _isButtonEnabled,
        onSave: _saveValue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '성별',
              style: AppTextStyles.headline1.bold.copyWith(
                color: colors.labelStrong,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '성별을 선택해주세요.',
              style: AppTextStyles.body2.normalRegular.copyWith(
                color: colors.labelNormal,
              ),
            ),

            const SizedBox(height: 24),

            Column(
              children:
                  genderOptions.map((String gender) {
                    final bool isSelected = _selectedValue == gender;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedValue = gender;
                          });
                          _checkButtonState();
                        },
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
                                style: AppTextStyles.body2.normalRegular
                                    .copyWith(color: colors.labelNormal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _saveValue() {
    if (_selectedValue != widget.currentValue) {
      Navigator.of(context).pop(_selectedValue);
    }
  }
}
