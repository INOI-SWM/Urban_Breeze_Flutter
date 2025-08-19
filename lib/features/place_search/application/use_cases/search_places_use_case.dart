import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';

import '../../domain/entities/place.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/exceptions/place_search_domain_exceptions.dart';
import '../../domain/repositories/place_search_repository.dart';

class SearchPlacesUseCase {
  const SearchPlacesUseCase({required PlaceSearchRepository repository})
    : _repository = repository;

  final PlaceSearchRepository _repository;

  Future<AppResult<SearchResult>> call({
    required String query,
    required double longitude,
    required double latitude,
  }) async {
    final String sanitizedQuery = _sanitizeQuery(query);
    if (sanitizedQuery.isEmpty) {
      return const AppFailure<SearchResult>(ValidationException('검색어를 입력해주세요'));
    }

    try {
      final SearchResult searchResult = await _repository.searchPlaces(
        query: sanitizedQuery,
        longitude: longitude,
        latitude: latitude,
      );

      final List<Place> uniquePlaces = _removeDuplicates(searchResult.places);
      final SearchResult uniqueSearchResult = SearchResult(
        query: sanitizedQuery,
        places: uniquePlaces,
        bbox: searchResult.bbox,
      );

      return AppSuccess<SearchResult>(uniqueSearchResult);
    } on EmptyQueryException catch (e) {
      return AppFailure<SearchResult>(e);
    } on NoResultsException catch (e) {
      return AppFailure<SearchResult>(e);
    } on NetworkException catch (e) {
      return AppFailure<SearchResult>(e);
    } on ServerException catch (e) {
      return AppFailure<SearchResult>(e);
    } on ParsingException catch (e) {
      return AppFailure<SearchResult>(e);
    } catch (e) {
      return const AppFailure<SearchResult>(
        ParsingException('검색 중 오류가 발생했습니다'),
      );
    }
  }

  // 앞뒤 공백 제거, 연속된 공백을 하나로 통합
  String _sanitizeQuery(String query) {
    return query.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // 중복 장소 제거
  List<Place> _removeDuplicates(List<Place> places) {
    final Set<String> seen = <String>{};
    final List<Place> result = <Place>[];

    for (final Place place in places) {
      final String key = _generateLocationKey(place.latitude, place.longitude);

      if (!seen.contains(key)) {
        seen.add(key);
        result.add(place);
      }
    }

    return result;
  }

  // 위도,경도로 고유 키 생성, 소수점 5자리(약 1.1m 단위)까지만 고려 => 1.1m 단위까지 같으면 같은 장소로 간주
  String _generateLocationKey(double latitude, double longitude) {
    final String lat = latitude.toStringAsFixed(5);
    final String lng = longitude.toStringAsFixed(5);
    return '$lat,$lng';
  }
}
