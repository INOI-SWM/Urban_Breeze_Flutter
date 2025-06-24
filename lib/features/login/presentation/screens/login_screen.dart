import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/auth/application/providers/user_session_notifier.dart';
import 'package:ridingmate/features/login/application/use_cases/auth_sign_in_facade.dart';
import 'package:ridingmate/features/login/di/auth_providers.dart';
import 'package:ridingmate/features/login/domain/entities/user.dart';
import 'package:ridingmate/features/login/domain/enums/login_provider.dart';
import 'package:ridingmate/features/login/presentation/widgets/login_button.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

      if (mounted && user != null) {
        await ref.read(userSessionProvider.notifier).setUserSession(user);
        if (!mounted) return;
        _showSuccessMessage(user);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(provider);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingProvider = null;
        });
      }
    }
  }

  void _showSuccessMessage(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('환영합니다, ${user.displayName ?? user.email}님!')),
    );
  }

  void _showErrorMessage(LoginProvider provider) {
    final String providerName = switch (provider) {
      LoginProvider.google => 'Google',
      LoginProvider.apple => 'Apple',
      LoginProvider.kakao => 'Kakao',
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$providerName 로그인에 실패했습니다.')));
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
