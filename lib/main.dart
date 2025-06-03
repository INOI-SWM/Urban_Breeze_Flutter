// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/app_theme.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riding Mate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Brightness currentBrightness = Theme.of(context).brightness;
    final SemanticColors semanticColors =
        currentBrightness == Brightness.light
            ? const LightSemanticColors()
            : const DarkSemanticColors();

    return SemanticTheme(
      data: semanticColors,
      child: Builder(
        builder:
            (BuildContext semanticContext) => Scaffold(
              appBar: AppBar(
                title: Text(
                  'Riding Mate App',
                  style: TextStyle(
                    color: semanticContext.semanticColor.labelNormal,
                  ),
                ),
                backgroundColor:
                    semanticContext.semanticColor.backgroundNormalNormal,
              ),
              body: Center(
                child: Text(
                  'Welcome to Riding Mate!',
                  style: AppTextStyles.body1.normalMedium.copyWith(
                    color: semanticContext.semanticColor.primaryNormal,
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
