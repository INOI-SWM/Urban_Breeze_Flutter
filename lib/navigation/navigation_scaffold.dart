import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/services/route_share_handler.dart';
import 'package:urban_breeze/features/home/presentation/screens/home_screen.dart';
import 'package:urban_breeze/features/my_route/presentation/screens/my_route_screen.dart';
import 'package:urban_breeze/features/profile/presentation/pages/profile_page.dart';
import 'package:urban_breeze/features/recommended_course/presentation/screens/recommended_course_screen.dart';
import 'package:urban_breeze/features/workout_history/presentation/pages/workout_history_page.dart';
import 'package:urban_breeze/navigation/bottom_navigation.dart';
import 'package:urban_breeze/navigation/navigation_providers.dart';
import 'package:urban_breeze/navigation/page_with_app_bar.dart';

class NavigationScaffold extends ConsumerStatefulWidget {
  const NavigationScaffold({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<NavigationScaffold> createState() => _NavigationScaffoldState();
}

class _NavigationScaffoldState extends ConsumerState<NavigationScaffold> {
  static final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    const RecommendedCourseScreen(),
    const MyRouteScreen(),
    const WorkoutHistoryPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // 딥링크 핸들러 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RouteShareHandler.initialize(ref, context);
      // 로그인 완료 후 대기 중인 딥링크 처리
      RouteShareHandler.processPendingRouteShare(ref, context);
    });
  }

  PreferredSizeWidget? _getAppBar(int currentIndex, BuildContext context) {
    final Widget currentPage = _pages[currentIndex];

    if (currentPage is PageWithAppBar) {
      // 현재 페이지가 PageWithAppBar를 구현했다면, 해당 페이지의 getAppBar 메서드를 호출
      return (currentPage as PageWithAppBar).getAppBar(context);
    }

    // PageWithAppBar를 구현하지 않은 페이지는 AppBar가 없거나 기본 AppBar를 반환
    return null; //또는 AppBar(title: const Text('기본 앱바')); //
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = ref.watch(bottomNavIndexProvider);

    // 최초 진입시 initialIndex 반영
    if (currentIndex == 0 && widget.initialIndex != 0) {
      // ignore: unused_result
      ref.read(bottomNavIndexProvider.notifier).state = widget.initialIndex;
    }

    return Scaffold(
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      appBar: _getAppBar(currentIndex, context),
      body: SafeArea(child: _pages[currentIndex]),
      bottomNavigationBar: BottomNavigation(
        currentIndex: currentIndex,
        onDestinationSelected: (int index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
