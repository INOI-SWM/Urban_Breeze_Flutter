// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/app_theme.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/ui/navigation/navigation_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        final Brightness currentBrightness = Theme.of(context).brightness;
        final SemanticColors semanticColors =
            currentBrightness == Brightness.light
                ? const LightSemanticColors()
                : const DarkSemanticColors();

        return SemanticTheme(
          data: semanticColors,
          child: MaterialApp(
            title: 'Riding Mate',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            builder: (BuildContext context, Widget? child) {
              return SemanticTheme(data: semanticColors, child: child!);
            },
            home: const NavigationScaffold(),
          ),
        );
      },
    );
  }
}
