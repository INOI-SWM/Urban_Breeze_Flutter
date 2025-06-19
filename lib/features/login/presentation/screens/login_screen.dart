import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/login/application/providers/auth_providers.dart';
import 'package:ridingmate/features/login/application/use_cases/sign_in_with_google_use_case.dart';
import 'package:ridingmate/features/login/domain/entities/user.dart';
import 'package:ridingmate/features/login/presentation/widgets/login_button.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isGoogleLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final SignInWithGoogleUseCase signInUseCase = ref.read(
        signInWithGoogleUseCaseProvider,
      );
      final User? user = await signInUseCase.execute();

      if (mounted && user != null) {
        // TODO: 로그인 성공 후 처리 (예: 홈 화면으로 이동)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('환영합니다, ${user.displayName ?? user.email}님!'),
            ),
          );
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
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
                if (_isGoogleLoading)
                  Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  )
                else
                  LoginButton(
                    text: 'Google로 계속하기',
                    iconPath: 'assets/icons/svg/google_logo.svg',
                    onPressed: _handleGoogleSignIn,
                  ),
                const SizedBox(height: 12),
                LoginButton(
                  text: 'Apple로 계속하기',
                  iconPath: 'assets/icons/svg/apple_logo.svg',
                  onPressed: () {
                    // TODO: Apple 로그인 처리
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
