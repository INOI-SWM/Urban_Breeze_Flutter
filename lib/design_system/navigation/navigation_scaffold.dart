import 'package:flutter/material.dart';
import 'package:ridingmate/core/theme/app_theme.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/core/theme/semantic_colors.dart';
import 'package:ridingmate/design_system/navigation/bottom_navigation_bar.dart';

class NavigationScaffold extends StatefulWidget {
  const NavigationScaffold({super.key});

  @override
  State<NavigationScaffold> createState() => _NavigationScaffoldState();
}

class _NavigationScaffoldState extends State<NavigationScaffold> {
  int _currentIndex = 0;

  static final List<Widget> _pages = <Widget>[
    // 각 화면 위젯으로 교체 필요. 예시 : const HomeScreen(),
    const Center(child: Text('홈')),
    const Center(child: Text('경로 생성')),
    const Center(child: Text('라이딩')),
    const Center(child: Text('운동 기록')),
    const Center(child: Text('MY')),
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
