import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_size.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_solid.dart';
import 'package:urban_breeze/shared/design_system/widgets/checkbox/custom_checkbox.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _privacyConsent = false;
  bool _locationConsent = false;

  bool get _isAllConsented => _privacyConsent && _locationConsent;

  Widget _buildConsentCheckbox({
    required String title,
    String? consentKey,
    bool isAllConsent = false,
    required SemanticColors colors,
  }) {
    final bool isChecked =
        isAllConsent
            ? _privacyConsent && _locationConsent
            : consentKey == 'privacy'
            ? _privacyConsent
            : _locationConsent;

    return Row(
      children: <Widget>[
        CustomCheckbox(
          value: isChecked,
          onChanged: (bool value) {
            setState(() {
              if (isAllConsent) {
                // 모두 동의 체크박스
                _privacyConsent = value;
                _locationConsent = value;
              } else {
                // 개별 체크박스
                if (consentKey == 'privacy') {
                  _privacyConsent = value;
                } else if (consentKey == 'location') {
                  _locationConsent = value;
                }
              }
            });
          },
          colors: colors,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: AppTextStyles.body1.readingRegular)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    return Scaffold(
      appBar: const CustomAppBar(centerTitle: true, title: '이용약관 동의'),
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                'assets/images/png/urban_breeze_logo.png',
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                '계속 진행하시려면 아래 권한에 동의해 주세요',
                style: AppTextStyles.heading2.bold,
              ),

              const SizedBox(height: 24),
              _buildConsentCheckbox(
                title: '개인정보처리방침 동의 (필수)',
                consentKey: 'privacy',
                colors: colors,
              ),
              const SizedBox(height: 16),
              _buildConsentCheckbox(
                title: '위치기반서비스 동의 (필수)',
                consentKey: 'location',
                colors: colors,
              ),
              const SizedBox(height: 16),
              //Separate line
              Divider(color: colors.lineNormalNormal, height: 1),
              const SizedBox(height: 16),
              _buildConsentCheckbox(
                title: '모든 약관에 동의합니다',
                isAllConsent: true,
                colors: colors,
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ButtonSolid(
                  backgroundColor: colors.primaryNormal,
                  textColor: colors.staticWhite,
                  size: ButtonSize.large,
                  text: '계속',
                  onPressed:
                      _isAllConsented
                          ? () {
                            // 동의 완료 후 프로필 설정 화면으로 이동
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<Widget>(
                                builder:
                                    (BuildContext context) =>
                                        const ProfileSetupScreen(),
                              ),
                            );
                          }
                          : null, // 모든 동의가 완료되지 않으면 버튼 비활성화
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
