import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/application/use_cases/update_agreement_use_case.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/entities/user_agreement.dart';
import 'package:urban_breeze/navigation/navigation_scaffold.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_size.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_solid.dart';
import 'package:urban_breeze/shared/design_system/widgets/checkbox/custom_checkbox.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';
import 'package:urban_breeze/shared/screens/webview_constant.dart';
import 'package:urban_breeze/shared/utils/webview_navigation.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen>
    with ErrorDisplayMixin {
  bool _serviceConsent = false;
  bool _privacyConsent = false;
  bool _locationConsent = false;
  bool _isSubmitting = false;

  bool get _isAllConsented =>
      _serviceConsent && _privacyConsent && _locationConsent;

  void _handleConsentChange(String? consentKey, bool isAllConsent, bool value) {
    setState(() {
      if (isAllConsent) {
        _serviceConsent = value;
        _privacyConsent = value;
        _locationConsent = value;
      } else {
        switch (consentKey) {
          case 'service':
            _serviceConsent = value;
            break;
          case 'privacy':
            _privacyConsent = value;
            break;
          case 'location':
            _locationConsent = value;
            break;
        }
      }
    });
  }

  void _handleConsentTap(String? consentKey, bool isAllConsent) {
    if (isAllConsent) {
      final bool newValue =
          !(_serviceConsent && _privacyConsent && _locationConsent);
      _handleConsentChange(consentKey, isAllConsent, newValue);
    } else {
      final bool currentValue = switch (consentKey) {
        'service' => _serviceConsent,
        'privacy' => _privacyConsent,
        'location' => _locationConsent,
        _ => false,
      };
      _handleConsentChange(consentKey, isAllConsent, !currentValue);
    }
  }

  Future<void> _submitAgreement() async {
    if (!_isAllConsented || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final UpdateAgreementUseCase updateUseCase = ref.read(
        updateAgreementUseCaseProvider,
      );

      final UserAgreement agreement = UserAgreement(
        termsOfServiceAgreed: _serviceConsent,
        privacyPolicyAgreed: _privacyConsent,
        locationServiceAgreed: _locationConsent,
        isCompleted: true, // 모든 필수 약관에 동의했으므로 true
      );

      final AppResult<UserAgreement> result = await updateUseCase.execute(
        agreement,
      );

      if (result.isSuccess) {
        AmplitudeAnalytics.logButtonClick('consent_agree_success');

        // 약관동의 완료 후 사용자의 isFirstLogin 상태를 false로 업데이트
        final User? currentUser = ref.read(userSessionNotifierProvider);
        if (currentUser != null) {
          final User updatedUser = currentUser.copyWith(isFirstLogin: false);
          await ref
              .read(userSessionNotifierProvider.notifier)
              .setUserSession(updatedUser);
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<Widget>(
              builder: (BuildContext context) => const NavigationScaffold(),
            ),
          );
        }
      } else {
        final String errorMessage =
            result is AppFailure<UserAgreement>
                ? result.exception.toString()
                : '약관 동의에 실패했습니다';
        if (mounted) {
          showErrorMessage(context, errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorMessage(context, '약관 동의 처리 중 오류가 발생했습니다: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildConsentCheckbox({
    required String title,
    String? consentKey,
    bool isAllConsent = false,
    required SemanticColors colors,
    String? detailText,
    VoidCallback? onDetailTap,
  }) {
    final bool isChecked =
        isAllConsent
            ? _serviceConsent && _privacyConsent && _locationConsent
            : switch (consentKey) {
              'service' => _serviceConsent,
              'privacy' => _privacyConsent,
              'location' => _locationConsent,
              _ => false,
            };

    return GestureDetector(
      onTap: () => _handleConsentTap(consentKey, isAllConsent),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: <Widget>[
            CustomCheckbox(
              value: isChecked,
              onChanged:
                  (bool value) =>
                      _handleConsentChange(consentKey, isAllConsent, value),
              colors: colors,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.body1.readingRegular,
                    ),
                  ),
                  if (detailText != null)
                    GestureDetector(
                      onTap: onDetailTap,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        detailText,
                        style: AppTextStyles.body1.readingRegular.copyWith(
                          color: colors.primaryNormal,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AmplitudeAnalytics.logScreenView('consent_screen');
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
              const SizedBox(height: 40),
              _buildConsentCheckbox(
                title: '서비스 이용약관 동의 (필수)',
                consentKey: 'service',
                colors: colors,
                detailText: '(자세히)',
                onDetailTap: () {
                  AmplitudeAnalytics.logButtonClick(
                    'consent_service_policy_detail',
                  );
                  WebViewNavigation.navigateToWebView(
                    context,
                    url: servicePolicyUrl,
                    title: '서비스 이용약관',
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildConsentCheckbox(
                title: '개인정보처리방침 동의 (필수)',
                consentKey: 'privacy',
                colors: colors,
                detailText: '(자세히)',
                onDetailTap: () {
                  AmplitudeAnalytics.logButtonClick(
                    'consent_privacy_policy_detail',
                  );
                  WebViewNavigation.navigateToWebView(
                    context,
                    url: privacyPolicyUrl,
                    title: '개인정보처리방침',
                  );
                },
              ),

              const SizedBox(height: 8),
              _buildConsentCheckbox(
                title: '위치기반 서비스 이용약관 동의 (필수)',
                consentKey: 'location',
                colors: colors,
                detailText: '(자세히)',
                onDetailTap: () {
                  AmplitudeAnalytics.logButtonClick(
                    'consent_location_policy_detail',
                  );
                  WebViewNavigation.navigateToWebView(
                    context,
                    url: locationPolicyUrl,
                    title: '위치기반서비스 약관',
                  );
                },
              ),
              const SizedBox(height: 8),
              //Separate line
              Divider(color: colors.lineNormalNormal, height: 1),
              const SizedBox(height: 8),
              _buildConsentCheckbox(
                title: '모든 약관에 동의합니다',
                isAllConsent: true,
                colors: colors,
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ButtonSolid(
                  backgroundColor:
                      (_isAllConsented && !_isSubmitting)
                          ? colors.primaryNormal
                          : colors.interactionDisable,
                  textColor:
                      (_isAllConsented && !_isSubmitting)
                          ? colors.staticWhite
                          : colors.labelAssistive,
                  size: ButtonSize.large,
                  text: _isSubmitting ? '처리중...' : '가입하기',
                  onPressed:
                      (_isAllConsented && !_isSubmitting)
                          ? () {
                            AmplitudeAnalytics.logButtonClick(
                              'consent_agree_done',
                            );
                            _submitAgreement();
                          }
                          : null, // 모든 동의가 완료되지 않거나 처리중이면 버튼 비활성화
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
