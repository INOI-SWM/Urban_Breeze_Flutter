import 'package:flutter/material.dart';
import 'package:ridingmate/features/profile/presentation/widgets/login_button.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
