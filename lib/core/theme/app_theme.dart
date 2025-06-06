import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart'; // For AppTextStyles

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    navigationBarTheme: NavigationBarThemeData(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
        Set<WidgetState> states,
      ) {
        return AppTextStyles.caption2.medium.copyWith(
          color:
              states.contains(WidgetState.selected)
                  ? const LightSemanticColors().primaryNormal
                  : const LightSemanticColors().interactionInactive,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
        Set<WidgetState> states,
      ) {
        return IconThemeData(
          color:
              states.contains(WidgetState.selected)
                  ? const LightSemanticColors().primaryNormal
                  : const LightSemanticColors().interactionInactive,
          size: 24.0,
        );
      }),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
        Set<WidgetState> states,
      ) {
        return AppTextStyles.caption2.medium.copyWith(
          color:
              states.contains(WidgetState.selected)
                  ? const DarkSemanticColors().primaryNormal
                  : const DarkSemanticColors().labelNeutral,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
        Set<WidgetState> states,
      ) {
        return IconThemeData(
          color:
              states.contains(WidgetState.selected)
                  ? const DarkSemanticColors().primaryNormal
                  : const DarkSemanticColors().labelNeutral,
        );
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
