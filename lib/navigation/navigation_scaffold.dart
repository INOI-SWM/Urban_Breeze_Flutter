import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/home/presentation/screens/home_screen.dart';
import 'package:ridingmate/features/my_route/presentation/screens/my_route_screen.dart';
import 'package:ridingmate/features/profile/presentation/pages/profile_page.dart';
import 'package:ridingmate/features/recommended_course/presentation/screens/recommended_course_screen.dart';
import 'package:ridingmate/features/workout_history/presentation/pages/workout_history_page.dart';
import 'package:ridingmate/navigation/bottom_navigation.dart';
import 'package:ridingmate/navigation/page_with_app_bar.dart';

class NavigationScaffold extends StatefulWidget {
  const NavigationScaffold({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<NavigationScaffold> createState() => _NavigationScaffoldState();
}

class _NavigationScaffoldState extends State<NavigationScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  static final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const RecommendedCourseScreen(),
    const MyRouteScreen(),
    const WorkoutHistoryPage(),
    const ProfilePage(),
  ];

  PreferredSizeWidget? _getAppBar() {
    final Widget currentPage = _pages[_currentIndex];

    if (currentPage is PageWithAppBar) {
      // 현재 페이지가 PageWithAppBar를 구현했다면, 해당 페이지의 getAppBar 메서드를 호출
      return (currentPage as PageWithAppBar).getAppBar(context);
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
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      appBar: _getAppBar(),
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
