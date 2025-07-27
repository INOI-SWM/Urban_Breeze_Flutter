import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/auth/application/use_cases/auth_sign_in_facade.dart';
import 'package:ridingmate/features/auth/di/auth_providers.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/auth/domain/enums/login_provider.dart';
import 'package:ridingmate/features/auth/presentation/widgets/login_button.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/presentation/mixins/error_display_mixin.dart';

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

    try {
      final AuthSignInFacade authSignInFacade = ref.read(
        authSignInFacadeProvider,
      );
      final User? user = await authSignInFacade.signIn(provider);
      //TODO : 로그인 null 반환하는거 처리 후 logout처럼 facade에서 상태관리하게 처리
      if (mounted && user != null) {
        await ref
            .read(userSessionNotifierProvider.notifier)
            .setUserSession(user);
        if (!mounted) return;
        showSuccessMessage(
          context,
          '환영합니다, ${user.displayName ?? user.email}님!',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final String providerName = switch (provider) {
          LoginProvider.google => 'Google',
          LoginProvider.apple => 'Apple',
          LoginProvider.kakao => 'Kakao',
        };
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
      appBar: CustomAppBar(
        centerTitle: true,
        actions: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.semanticColor.interactionInactive,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                customBorder: const CircleBorder(),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: context.semanticColor.staticWhite,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
        ),
      ),
    );
  }
}
