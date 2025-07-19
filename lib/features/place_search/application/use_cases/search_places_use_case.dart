import '../../domain/entities/place.dart';
import '../../domain/exceptions/place_search_domain_exceptions.dart';
import '../../domain/repositories/place_search_repository.dart';

sealed class PlaceSearchResult<T> {
  const PlaceSearchResult();
}

class PlaceSearchSuccess<T> extends PlaceSearchResult<T> {
  const PlaceSearchSuccess(this.places);
  final List<Place> places;
}

class PlaceSearchFailure<T> extends PlaceSearchResult<T> {
  const PlaceSearchFailure(this.message);
  final String message;
}

class SearchPlacesUseCase {
  const SearchPlacesUseCase({required PlaceSearchRepository repository})
    : _repository = repository;

  final PlaceSearchRepository _repository;

  Future<PlaceSearchResult<List<Place>>> call({required String query}) async {
    final String sanitizedQuery = _sanitizeQuery(query);
    if (sanitizedQuery.isEmpty) {
      return const PlaceSearchFailure<List<Place>>('검색어를 입력해주세요');
    }

    try {
      final List<Place> places = await _repository.searchPlaces(
        query: sanitizedQuery,
      );

      final List<Place> uniquePlaces = _removeDuplicates(places);
      return PlaceSearchSuccess<List<Place>>(uniquePlaces);
    } on EmptyQueryException catch (e) {
      return PlaceSearchFailure<List<Place>>(e.message);
    } on NoResultsException catch (e) {
      return PlaceSearchFailure<List<Place>>(e.message);
    } on PlaceSearchNetworkException catch (e) {
      return PlaceSearchFailure<List<Place>>(e.message);
    } on PlaceSearchServerException catch (e) {
      return PlaceSearchFailure<List<Place>>(e.message);
    } on PlaceSearchParsingException catch (e) {
      return PlaceSearchFailure<List<Place>>(e.message);
    } catch (e) {
      return const PlaceSearchFailure<List<Place>>('검색 중 오류가 발생했습니다');
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
