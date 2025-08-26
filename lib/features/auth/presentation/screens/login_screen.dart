import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/application/use_cases/auth_sign_in_facade.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';
import 'package:urban_breeze/features/auth/presentation/widgets/login_button.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with ErrorDisplayMixin {
  LoginProvider? _loadingProvider;

  bool _isLoading(LoginProvider provider) => _loadingProvider == provider;

  Future<void> _handleSignIn(LoginProvider provider) async {
    setState(() {
      _loadingProvider = provider;
    });

    // 로그인 버튼 클릭 이벤트
    final String providerName = _getProviderName(provider);
    AmplitudeAnalytics.logButtonClick(
      'login_button',
      additionalProperties: <String, dynamic>{'provider': providerName},
    );

    try {
      final AuthSignInFacade authSignInFacade = ref.read(
        authSignInFacadeProvider,
      );
      final AppResult<User> result = await authSignInFacade.signIn(provider);
      final User? user = result.dataOrNull;
      if (!mounted) return;

      if (user == null) {
        AmplitudeAnalytics.logEvent(
          'user_login_failed',
          properties: <String, dynamic>{'provider': providerName},
        );

        showErrorMessage(context, '로그인에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (e) {
      if (mounted) {
        final String providerName = _getProviderName(provider);

        // 로그인 실패 이벤트
        AmplitudeAnalytics.logEvent(
          'user_login_failed',
          properties: <String, dynamic>{
            'provider': providerName,
            'error_type': 'exception',
            'error_message': e.toString(),
          },
        );

        showErrorMessage(context, '$providerName 로그인에 실패했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingProvider = null;
        });
      }
    }
  }

  String _getProviderName(LoginProvider provider) {
    return switch (provider) {
      LoginProvider.google => 'Google',
      LoginProvider.apple => 'Apple',
      LoginProvider.kakao => 'Kakao',
    };
  }

  Widget _buildLoginButton({
    required String text,
    required String iconPath,
    required LoginProvider provider,
  }) {
    if (_isLoading(provider)) {
      return Container(
        height: 48,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    return LoginButton(
      text: text,
      iconPath: iconPath,
      onPressed: () => _handleSignIn(provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(centerTitle: true, title: '로그인'),
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/png/urban_breeze_logo.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '가장 시원한 도시의 바람이 기다립니다',
                    style: AppTextStyles.heading2.bold.copyWith(
                      color: context.semanticColor.labelNormal,
                    ),
                  ),
                ],
              ),

              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildLoginButton(
                      text: 'Kakao로 계속하기',
                      iconPath: 'assets/icons/svg/kakao_logo.svg',
                      provider: LoginProvider.kakao,
                    ),
                    const SizedBox(height: 12),
                    _buildLoginButton(
                      text: 'Google로 계속하기',
                      iconPath: 'assets/icons/svg/google_logo.svg',
                      provider: LoginProvider.google,
                    ),
                    if (Platform.isIOS) ...<Widget>[
                      const SizedBox(height: 12),
                      _buildLoginButton(
                        text: 'Apple로 계속하기',
                        iconPath: 'assets/icons/svg/apple_logo.svg',
                        provider: LoginProvider.apple,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
