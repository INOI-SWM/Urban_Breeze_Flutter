import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/login/presentation/screens/login_screen.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_solid.dart';

class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ButtonSolid(
          text: '로그인하기',
          backgroundColor: context.semanticColor.primaryNormal,
          textColor: context.semanticColor.staticWhite,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const LoginScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
