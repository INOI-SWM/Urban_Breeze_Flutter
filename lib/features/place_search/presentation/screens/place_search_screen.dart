import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/place_search/application/use_cases/search_places_use_case.dart';
import 'package:ridingmate/features/place_search/di/place_search_providers.dart';
import 'package:ridingmate/features/place_search/domain/entities/place.dart';
import 'package:ridingmate/features/place_search/domain/exceptions/place_search_domain_exceptions.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/search_app_bar.dart';

class PlaceSearchScreen extends ConsumerStatefulWidget {
  const PlaceSearchScreen({super.key});

  @override
  ConsumerState<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends ConsumerState<PlaceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;
  List<Place> _searchResults = <Place>[];
  Timer? _debounceTimer; // 실시간 검색 시 과도한 API 호출 방지용 타이머

  late final SearchPlacesUseCase _searchPlacesUseCase;

  @override
  void initState() {
    super.initState();
    _searchPlacesUseCase = ref.read(searchPlacesUseCaseProvider);

    // 화면 진입 시 검색 필드에 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchTextChanged(String query) {
    // 실시간 검색 (300ms 디바운스)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final List<Place> results = await _searchPlacesUseCase.call(query: query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });

        String errorMessage = '검색 중 오류가 발생했습니다';
        if (e is PlaceSearchDomainException) {
          errorMessage = e.message;
        }

        _showErrorSnackBar(errorMessage);
      }
    }
  }

  void _selectPlace(Place place) {
    // 선택된 장소를 이전 화면으로 반환
    Navigator.of(context).pop(place);
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.trim().isEmpty) {
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

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.search_off,
              size: 64,
              color: context.semanticColor.labelDisable,
            ),
            const SizedBox(height: 16),
            Text('검색 결과가 없습니다', style: AppTextStyles.body1.normalRegular),
            const SizedBox(height: 8),
            Text(
              '다른 검색어로 시도해보세요',
              style: AppTextStyles.body2.normalRegular.copyWith(
                color: context.semanticColor.labelDisable,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (BuildContext context, int index) {
        final Place place = _searchResults[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: InkWell(
            onTap: () => _selectPlace(place),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  place.title,
                  style: AppTextStyles.body1.normalRegular,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  place.roadAddress.isNotEmpty
                      ? place.roadAddress
                      : place.address,
                  style: AppTextStyles.body2.normalRegular.copyWith(
                    color: context.semanticColor.labelDisable,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 30),
            SearchAppBar(
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
              onSearchChanged: _onSearchTextChanged,
              onSearchSubmitted: _performSearch,
              onBackPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }
}
