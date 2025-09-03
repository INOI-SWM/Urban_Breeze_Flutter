import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/place_search/application/use_cases/search_places_use_case.dart';
import 'package:urban_breeze/features/place_search/di/place_search_providers.dart';
import 'package:urban_breeze/features/place_search/domain/entities/place.dart';
import 'package:urban_breeze/features/place_search/domain/entities/search_result.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/get_current_location_use_case.dart';
import 'package:urban_breeze/features/route_planning/di/route_providers.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/search_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/map/map_constants.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class PlaceSearchScreen extends ConsumerStatefulWidget {
  const PlaceSearchScreen({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  ConsumerState<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends ConsumerState<PlaceSearchScreen>
    with ErrorDisplayMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;
  List<Place> _searchResults = <Place>[];
  SearchResult? _lastSearchResult; // 마지막 검색 결과 저장
  Timer? _debounceTimer; // 실시간 검색 시 과도한 API 호출 방지용 타이머

  late final SearchPlacesUseCase _searchPlacesUseCase;
  late final GetCurrentLocationUseCase _getCurrentLocationUseCase;

  LatLng? _currentLocation;
  static const LatLng _defaultLocation = MapConstants.seoulCityHall;

  @override
  void initState() {
    super.initState();
    _searchPlacesUseCase = ref.read(searchPlacesUseCaseProvider);
    _getCurrentLocationUseCase = ref.read(getCurrentLocationUseCaseProvider);

    // 초기 위치 사용 (null인 경우 현재 위치 가져오기)
    _currentLocation = widget.initialLocation;
    if (_currentLocation == null) {
      _getCurrentLocation();
    }

    // 화면 진입 시 검색 필드에 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      AmplitudeAnalytics.logScreenView('place_search_screen');
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
      _performRealtimeSearch(query);
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      final LatLng? location = await _getCurrentLocationUseCase.execute();
      if (mounted) {
        setState(() {
          _currentLocation = location;
        });
      }
    } catch (e) {
      // 위치 정보를 가져올 수 없는 경우 기본 위치 사용
      if (mounted) {
        setState(() {
          _currentLocation = _defaultLocation;
        });
      }
    }
  }

  Future<void> _performRealtimeSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    AmplitudeAnalytics.logEvent(
      'place_search_executed',
      properties: <String, dynamic>{
        'query': query,
        'query_length': query.length,
        'search_type': 'realtime',
      },
    );

    final LatLng searchLocation = _currentLocation ?? _defaultLocation;

    setState(() {
      _isSearching = true;
    });

    final AppResult<SearchResult> result = await _searchPlacesUseCase.call(
      query: query,
      longitude: searchLocation.longitude,
      latitude: searchLocation.latitude,
    );

    if (mounted) {
      setState(() {
        _isSearching = false;
      });

      switch (result) {
        case final AppSuccess<SearchResult> success:
          // 실시간 검색: API 응답이 있으면 새 결과 표시, 없으면 기존 결과에서 필터링
          if (success.data.places.isNotEmpty) {
            setState(() {
              _searchResults = success.data.places;
              _lastSearchResult = success.data;
            });
          } else if (_lastSearchResult != null &&
              _lastSearchResult!.places.isNotEmpty) {
            final List<Place> filteredPlaces = _filterPlacesByQuery(
              _lastSearchResult!.places,
              query.trim(),
            );
            setState(() {
              _searchResults = filteredPlaces;
            });
          } else {
            setState(() {
              _searchResults.clear();
              _lastSearchResult = null;
            });
          }

          AmplitudeAnalytics.logEvent(
            'place_search_success',
            properties: <String, dynamic>{
              'query': query,
              'result_count': _searchResults.length,
            },
          );
        case final AppFailure<SearchResult> failure:
          // 실시간 검색 실패 시에는 기존 결과 유지
          AmplitudeAnalytics.logEvent(
            'place_search_failed',
            properties: <String, dynamic>{
              'query': query,
              'error_type': failure.exceptionOrNull?.runtimeType.toString(),
            },
          );
      }
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

    AmplitudeAnalytics.logEvent(
      'place_search_executed',
      properties: <String, dynamic>{
        'query': query,
        'query_length': query.length,
        'search_type': 'realtime',
      },
    );

    final LatLng searchLocation = _currentLocation ?? _defaultLocation;

    setState(() {
      _isSearching = true;
    });

    final AppResult<SearchResult> result = await _searchPlacesUseCase.call(
      query: query,
      longitude: searchLocation.longitude,
      latitude: searchLocation.latitude,
    );

    if (mounted) {
      setState(() {
        _isSearching = false;
      });

      switch (result) {
        case final AppSuccess<SearchResult> success:
          setState(() {
            _searchResults = success.data.places;
            _lastSearchResult = success.data;
          });

          AmplitudeAnalytics.logEvent(
            'place_search_success',
            properties: <String, dynamic>{
              'query': query,
              'result_count': success.data.places.length,
            },
          );
        case final AppFailure<SearchResult> failure:
          // RETURN 검색 실패 시 검색 결과를 초기화
          setState(() {
            _searchResults.clear();
            _lastSearchResult = null;
          });

          AmplitudeAnalytics.logEvent(
            'place_search_failed',
            properties: <String, dynamic>{
              'query': query,
              'error_type': failure.exceptionOrNull?.runtimeType.toString(),
            },
          );
      }
    }
  }

  // 띄어쓰기 차이를 무시하고 문자열이 같은 결과만 필터링
  List<Place> _filterPlacesByQuery(List<Place> places, String query) {
    final String normalizedQuery = query.replaceAll(' ', '').toLowerCase();
    return places.where((Place place) {
      final String normalizedTitle =
          place.title.replaceAll(' ', '').toLowerCase();
      final String normalizedAddress =
          place.address.replaceAll(' ', '').toLowerCase();

      return normalizedTitle.contains(normalizedQuery) ||
          normalizedAddress.contains(normalizedQuery);
    }).toList();
  }

  void _selectPlace(Place place) {
    AmplitudeAnalytics.logEvent(
      'place_search_place_selected',
      properties: <String, dynamic>{
        'place_title': place.title,
        'place_address': place.address,
        'place_latitude': place.latitude,
        'place_longitude': place.longitude,
      },
    );

    Navigator.of(context).pop(place);
  }

  void _selectAllPlaces() {
    if (_searchResults.isNotEmpty && _lastSearchResult != null) {
      if (_searchResults.length == 1) {
        _selectPlace(_searchResults.first);
        return;
      }

      AmplitudeAnalytics.logEvent(
        'place_search_all_selected',
        properties: <String, dynamic>{
          'total_places': _searchResults.length,
          'query': _lastSearchResult!.query,
        },
      );

      Navigator.of(context).pop(_lastSearchResult);
    }
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: AppLoadingIndicator());
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
                  place.address,
                  style: AppTextStyles.body2.normalRegular.copyWith(
                    color: context.semanticColor.labelAlternative,
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
              onSearchSubmitted: (String query) async {
                AmplitudeAnalytics.logEvent(
                  'place_search_submitted',
                  properties: <String, dynamic>{
                    'query': query,
                    'query_length': query.length,
                    'search_type': 'submitted',
                  },
                );

                // RETURN 버튼을 눌렀을 때 검색을 한 번 더 진행
                await _performSearch(query);

                // 검색 결과가 있으면 모든 결과 반환, 없으면 결과 없음 창 표시
                if (_searchResults.isNotEmpty) {
                  _selectAllPlaces();
                }
                // 결과가 없으면 _buildSearchResults()에서 자동으로 "검색 결과가 없습니다" 창이 표시됨
              },
              onBackPressed: () {
                // 뒤로가기 이벤트
                AmplitudeAnalytics.logButtonClick('place_search_back');
                Navigator.of(context).pop();
              },
            ),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }
}
