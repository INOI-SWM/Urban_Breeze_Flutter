import '../../data/exceptions/place_search_exceptions.dart';
import '../../domain/entities/place.dart';
import '../../domain/repositories/place_search_repository.dart';

class SearchPlacesUseCase {
  const SearchPlacesUseCase({required PlaceSearchRepository repository})
    : _repository = repository;

  final PlaceSearchRepository _repository;

  Future<List<Place>> call({required String query, int maxResults = 5}) async {
    final String sanitizedQuery = _sanitizeQuery(query);
    if (sanitizedQuery.isEmpty) {
      throw const NoResultsException('검색어를 입력해주세요');
    }

    final int validatedMaxResults = _validateMaxResults(maxResults);

    final List<Place> places = await _repository.searchPlaces(
      query: sanitizedQuery,
      display: validatedMaxResults,
    );

    return _removeDuplicates(places);
  }

  // 앞뒤 공백 제거, 연속된 공백을 하나로 통합
  String _sanitizeQuery(String query) {
    return query.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // 네이버 API 허용 범위: 1-5
  int _validateMaxResults(int maxResults) {
    if (maxResults < 1) return 1;
    if (maxResults > 5) return 5;
    return maxResults;
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
