import 'package:flutter/material.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart'; // For AppTextStyles

class AppTheme {
  static SemanticColors getSemanticColors(Brightness brightness) {
    return brightness == Brightness.light
        ? const LightSemanticColors()
        : const DarkSemanticColors();
  }

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    navigationBarTheme: _buildNavigationBarThemeData(
      getSemanticColors(Brightness.light),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    navigationBarTheme: _buildNavigationBarThemeData(
      getSemanticColors(Brightness.dark),
    ),
  );

  static NavigationBarThemeData _buildNavigationBarThemeData(
    SemanticColors colors,
  ) {
    return NavigationBarThemeData(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
        Set<WidgetState> states,
      ) {
        return AppTextStyles.caption2.medium.copyWith(
          color:
              states.contains(WidgetState.selected)
                  ? colors.primaryNormal
                  : colors.interactionInactive,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((
        Set<WidgetState> states,
      ) {
        return IconThemeData(
          color:
              states.contains(WidgetState.selected)
                  ? colors.primaryNormal
                  : colors.interactionInactive,
          size: 24.0,
        );
      }),
    );
  }
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
