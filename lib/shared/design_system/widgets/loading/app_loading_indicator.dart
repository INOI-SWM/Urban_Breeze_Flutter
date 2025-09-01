import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({super.key, this.strokeWidth = 3.0, this.size});

  final double strokeWidth;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        context.semanticColor.primaryNormal,
      ),
      strokeWidth: strokeWidth,
    );
  }
}
