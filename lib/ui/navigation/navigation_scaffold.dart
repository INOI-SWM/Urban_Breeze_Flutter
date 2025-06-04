import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/app_theme.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/ui/navigation/bottom_navigation_bar.dart';
import 'package:ridingmate/ui/screens/history_screen.dart';
import 'package:ridingmate/ui/screens/home_screen.dart';
import 'package:ridingmate/ui/screens/my_screen.dart';
import 'package:ridingmate/ui/screens/riding_screen.dart';
import 'package:ridingmate/ui/screens/route_screen.dart';

class NavigationScaffold extends StatefulWidget {
  const NavigationScaffold({super.key});

  @override
  State<NavigationScaffold> createState() => _NavigationScaffoldState();
}

class _NavigationScaffoldState extends State<NavigationScaffold> {
  int _currentIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const RouteScreen(),
    const RidingScreen(),
    const HistoryScreen(),
    const MyScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Brightness currentBrightness = Theme.of(context).brightness;
    final SemanticColors semanticColors =
        currentBrightness == Brightness.light
            ? const LightSemanticColors()
            : const DarkSemanticColors();

    return SemanticTheme(
      data: semanticColors,
      child: Builder(
        builder:
            (BuildContext semanticContext) => Scaffold(
              appBar: AppBar(
                title: Text(
                  'Riding Mate App',
                  style: TextStyle(
                    color: semanticContext.semanticColor.labelNormal,
                  ),
                ),
                backgroundColor:
                    semanticContext.semanticColor.backgroundNormalNormal,
              ),
              body: _pages[_currentIndex],
              bottomNavigationBar: AppNavigationBar(
                currentIndex: _currentIndex,
                onDestinationSelected: _onDestinationSelected,
              ),
            ),
      ),
    );
  }
}
