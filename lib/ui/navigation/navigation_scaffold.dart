import 'package:flutter/material.dart';
import 'package:ridingmate/ui/navigation/bottom_navigation.dart';
import 'package:ridingmate/ui/screens/history_screen.dart';
import 'package:ridingmate/ui/screens/home_screen.dart';
import 'package:ridingmate/ui/screens/my_screen.dart';
import 'package:ridingmate/ui/screens/page_with_app_bar.dart';
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

  PreferredSizeWidget? _getAppBar() {
    final Widget currentPage = _pages[_currentIndex];

    if (currentPage is PageWithAppBar) {
      // 현재 페이지가 PageWithAppBar를 구현했다면, 해당 페이지의 getAppBar 메서드를 호출
      return currentPage.getAppBar(context);
    }

    // PageWithAppBar를 구현하지 않은 페이지는 AppBar가 없거나 기본 AppBar를 반환
    return null; //또는 AppBar(title: const Text('기본 앱바')); //
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar(),
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
