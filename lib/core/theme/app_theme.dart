import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart'; // For AppTextStyles

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.caption2.medium.copyWith(
            color: const LightSemanticColors().primaryNormal,
          );
        }
        return AppTextStyles.caption2.medium.copyWith(
          color: const LightSemanticColors().labelNeutral,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: const LightSemanticColors().primaryNormal,
          );
        }
        return IconThemeData(color: const LightSemanticColors().labelNeutral);
      }),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return AppTextStyles.caption2.medium.copyWith(
            color: const DarkSemanticColors().primaryNormal,
          );
        }
        return AppTextStyles.caption2.medium.copyWith(
          color: const DarkSemanticColors().labelNeutral,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(color: const DarkSemanticColors().primaryNormal);
        }
        return IconThemeData(color: const DarkSemanticColors().labelNeutral);
      }),
    ),
  );
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
