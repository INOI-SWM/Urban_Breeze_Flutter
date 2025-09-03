import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';

import '../../domain/entities/place.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/place_search_repository.dart';
import 'filter_places_use_case.dart';

class PerformRealtimeSearchUseCase {
  const PerformRealtimeSearchUseCase({
    required PlaceSearchRepository repository,
    required FilterPlacesUseCase filterPlacesUseCase,
  }) : _repository = repository,
       _filterPlacesUseCase = filterPlacesUseCase;

  final PlaceSearchRepository _repository;
  final FilterPlacesUseCase _filterPlacesUseCase;

  Future<AppResult<SearchResult>> execute({
    required String query,
    required double longitude,
    required double latitude,
    SearchResult? lastSearchResult,
  }) async {
    // 검색어 validation
    if (query.trim().isEmpty) {
      return const AppFailure<SearchResult>(ValidationException('검색어를 입력해주세요'));
    }

    // API 검색 실행
    final AppResult<SearchResult> result = AppSuccess<SearchResult>(
      await _repository.searchPlaces(
        query: query,
        longitude: longitude,
        latitude: latitude,
      ),
    );

    switch (result) {
      case final AppSuccess<SearchResult> success:
        // API 응답이 있으면 새 결과 반환
        if (success.data.places.isNotEmpty) {
          return result;
        }

        // API 응답이 비어있고 기존 결과가 있으면 필터링
        if (lastSearchResult != null && lastSearchResult.places.isNotEmpty) {
          final List<Place> filteredPlaces = _filterPlacesUseCase.execute(
            lastSearchResult.places,
            query.trim(),
          );

          return AppSuccess<SearchResult>(
            SearchResult(
              query: query,
              places: filteredPlaces,
              bbox: lastSearchResult.bbox,
            ),
          );
        }

        // API 응답도 없고 기존 결과도 없으면 빈 결과
        return AppSuccess<SearchResult>(
          SearchResult(query: query, places: <Place>[], bbox: null),
        );

      case final AppFailure<SearchResult> failure:
        return failure;
    }
  }
}
