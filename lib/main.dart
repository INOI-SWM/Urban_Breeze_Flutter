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
    return MaterialApp(
      title: 'Riding Mate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const NavigationScaffold(),
      builder: (BuildContext context, Widget? child) {
        final SemanticColors semanticColors = AppTheme.getSemanticColors(
          Theme.of(context).brightness,
        );

        return SemanticTheme(data: semanticColors, child: child!);
      },
    );
  }
}
