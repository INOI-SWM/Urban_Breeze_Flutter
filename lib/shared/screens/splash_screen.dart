import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      body: Center(
        child: Image.asset(
          'assets/images/png/urban_breeze_logo.png',
          height: 250,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
