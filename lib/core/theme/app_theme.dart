import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(brightness: Brightness.light);

  static final ThemeData darkTheme = ThemeData(brightness: Brightness.dark);
}

class SemanticTheme extends InheritedWidget {
  const SemanticTheme({super.key, required this.data, required super.child});

  final SemanticColors data;

  static SemanticColors of(BuildContext context) {
    final SemanticTheme? result =
        context.dependOnInheritedWidgetOfExactType<SemanticTheme>();
    assert(result != null, 'No SemanticTheme found in context');
    return result!.data;
  }

  @override
  bool updateShouldNotify(covariant SemanticTheme oldWidget) {
    return oldWidget.data != data;
  }
}
