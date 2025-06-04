// lib/main.dart
import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/app_theme.dart';
import 'package:ridingmate/design_system/navigation/navigation_scaffold.dart';

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
    );
  }
}
