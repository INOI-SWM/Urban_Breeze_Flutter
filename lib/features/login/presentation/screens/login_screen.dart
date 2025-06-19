import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/login/presentation/widgets/login_button.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                LoginButton(
                  text: 'Google로 계속하기',
                  iconPath: 'assets/icons/svg/google_logo.svg',
                  onPressed: () {
                    // TODO: Google 로그인 처리
                  },
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
