import 'package:flutter/material.dart';
import 'package:ridingmate/features/route_list/application/services/route_list_service.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/card/card_normal.dart';
import 'package:ridingmate/shared/design_system/widgets/category/category_filter.dart';

class RouteListScreen extends StatefulWidget {
  const RouteListScreen({super.key});

  @override
  State<RouteListScreen> createState() => _RouteListScreenState();
}

class _RouteListScreenState extends State<RouteListScreen> {
  final List<String> categories = <String>['내가 만든 경로', '공유 받은 경로'];
  final Set<String> selectedCategories = <String>{'내가 만든 경로'};

  List<Map<String, dynamic>> routeList = <Map<String, dynamic>>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRouteList();
  }

  void onCategorySelected(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
    _loadRouteList();
  }

  Future<void> _loadRouteList() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> routes =
        await RouteListService.fetchRouteList(
          categoryFilter: selectedCategories,
        );
    setState(() {
      routeList = routes;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CustomAppBar(
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chevron_left),
          ),
          title: '경로 목록',
          actions: <Widget>[
            IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: <Widget>[
              CategoryFilter(
                categories: categories,
                selectedCategories: selectedCategories,
                onCategorySelected: onCategorySelected,
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : routeList.isEmpty
                    ? const Center(child: Text('경로가 없습니다'))
                    : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: routeList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> route = routeList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CardNormal(
                            thumbnailPath: route['thumbnailPath'],
                            sourceType: route['sourceType'],
                            badgeText: route['badgeText'],
                            title: route['title'],
                            createDate: route['createDate'],
                            distance: route['distance'],
                            elevation: route['elevation'],
                          ),
                        );
                      },
                    ),
          ),
        ),
      ],
    );
  }
}
