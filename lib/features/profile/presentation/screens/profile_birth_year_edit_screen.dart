import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/profile/presentation/widgets/profile_edit_app_bar.dart';
import 'package:ridingmate/features/profile/presentation/widgets/profile_edit_layout.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';

class ProfileBirthYearEditScreen extends StatefulWidget {
  const ProfileBirthYearEditScreen({super.key, required this.currentValue});

  final String currentValue;

  @override
  State<ProfileBirthYearEditScreen> createState() =>
      _ProfileBirthYearEditScreenState();
}

class _ProfileBirthYearEditScreenState
    extends State<ProfileBirthYearEditScreen> {
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
    final int currentYear = DateTime.now().year;
    final List<String> yearOptions = <String>[];

    for (int year = currentYear; year >= 1950; year--) {
      yearOptions.add(year.toString());
    }

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: ProfileEditAppBar(
        title: '출생년도',
        isButtonEnabled: _isButtonEnabled,
        onSave: _saveValue,
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
              itemCount: yearOptions.length,
              itemBuilder: (BuildContext context, int index) {
                final String year = yearOptions[index];
                final bool isSelected = _selectedValue == year;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedValue = year;
                    });
                    _checkButtonState();
                  },
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

  void _saveValue() {
    if (_selectedValue != widget.currentValue) {
      Navigator.of(context).pop(_selectedValue);
    }
  }
}
