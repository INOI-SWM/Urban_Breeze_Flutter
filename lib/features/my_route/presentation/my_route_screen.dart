import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/my_route/application/services/my_route_service.dart';
import 'package:ridingmate/features/my_route/presentation/widgets/sort_modal.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:ridingmate/shared/design_system/widgets/card/route_card.dart';
import 'package:ridingmate/shared/design_system/widgets/chip/chip_filter.dart';

class MyRouteScreen extends StatefulWidget {
  const MyRouteScreen({super.key});

  @override
  State<MyRouteScreen> createState() => _MyRouteScreenState();
}

class _MyRouteScreenState extends State<MyRouteScreen> {
  String selectedSortOption = SortModal.sortOptions.first;

  List<Map<String, dynamic>> routeList = <Map<String, dynamic>>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRouteList();
  }

  void _showSortModal() {
    SortModal.show(
      context: context,
      selectedOption: selectedSortOption,
      onOptionSelected: (String option) {
        setState(() {
          selectedSortOption = option;
        });
        // TODO: 정렬 로직 구현
      },
    );
  }

  void _showFilterModal() {
    // TODO: 필터 모달 구현
  }

  Future<void> _loadRouteList() async {
    setState(() {
      isLoading = true;
    });

    final List<Map<String, dynamic>> routes =
        await RouteListService.fetchRouteList();
    setState(() {
      routeList = routes;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Column(
      children: <Widget>[
        CustomAppBar(
          leading: CustomIconButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () {},
          ),
          title: '나의 경로',
          actions: <Widget>[
            IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: <Widget>[
              ChipFilter(
                text: selectedSortOption,
                size: ChipFilterSize.xsmall,
                type: ChipFilterType.outlined,
                textColor: colors.labelAlternative,
                iconColor: colors.labelAlternative,
                borderColor: colors.lineNormalNeutral,
                onPressed: _showSortModal,
              ),
              const SizedBox(width: 16),
              ChipFilter(
                text: '필터',
                size: ChipFilterSize.xsmall,
                type: ChipFilterType.outlined,
                textColor: colors.labelAlternative,
                iconColor: colors.labelAlternative,
                borderColor: colors.lineNormalNeutral,
                onPressed: _showFilterModal,
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
                          child: RouteCard(
                            thumbnailPath: route['thumbnailPath'],
                            sourceType: route['sourceType'],
                            userProfileImage: route['userProfileImage'],
                            userName: route['userName'],
                            routeTitle: route['title'],
                            date: route['createDate'],
                            distance: route['distance'],
                            elevation: route['elevation'],
                            onTap: () {
                              // TODO: 경로 상세 화면으로 이동
                            },
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
