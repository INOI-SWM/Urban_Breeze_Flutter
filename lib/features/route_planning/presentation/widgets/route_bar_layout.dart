import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';

class RouteBarLayout extends StatelessWidget {
  const RouteBarLayout({
    super.key,
    required this.topNavigationBar,
    required this.content,
  });

  final Widget topNavigationBar;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.semanticColor.backgroundNormalNormal,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[topNavigationBar, content],
        ),
      ),
    );
  }
}
