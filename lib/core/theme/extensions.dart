import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/app_theme.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';

extension BuildContextSemanticColors on BuildContext {
  SemanticColors get semanticColor {
    return SemanticTheme.of(this);
  }
}
