import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/search_app_bar.dart';

class PlaceSearchScreen extends StatefulWidget {
  const PlaceSearchScreen({super.key});

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.search,
            size: 64,
            color: context.semanticColor.labelDisable,
          ),
          const SizedBox(height: 16),
          Text(
            '검색어를 입력해주세요',
            style: AppTextStyles.body1.normalRegular.copyWith(
              color: context.semanticColor.labelDisable,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      body: Column(
        children: <Widget>[
          const SizedBox(height: 54),
          SearchAppBar(
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
            onSearchChanged: (String query) {
              // TODO: 검색 로직 구현 예정
            },
            onSearchSubmitted: (String query) {
              // TODO: 검색 실행 로직 구현 예정
            },
            onBackPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }
}
