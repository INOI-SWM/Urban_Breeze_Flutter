import 'package:urban_breeze/features/place_search/data/models/place_search_response_model.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';

import '../../domain/entities/place.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/exceptions/place_search_domain_exceptions.dart';
import '../../domain/repositories/place_search_repository.dart';
import '../datasources/remote_place_search_datasource.dart';

class PlaceSearchRepositoryImpl implements PlaceSearchRepository {
  const PlaceSearchRepositoryImpl({
    required RemotePlaceSearchDataSource dataSource,
  }) : _dataSource = dataSource;

  final RemotePlaceSearchDataSource _dataSource;

  @override
  Future<SearchResult> searchPlaces({
    required String query,
    required double longitude,
    required double latitude,
  }) async {
    try {
      final PlaceSearchResponseModel response = await _dataSource.searchPlaces(
        query: query,
        longitude: longitude,
        latitude: latitude,
      );

      if (response.data.documents.isEmpty) {
        throw const NoResultsException('검색 결과가 없습니다');
      }

      // 응답 데이터를 Place 엔티티로 변환
      final List<Place> places =
          response.data.documents
              .map((PlaceSearchDocument document) => document.toPlace())
              .where((Place place) => _isValidPlace(place))
              .toList();

      if (places.isEmpty) {
        throw const NoResultsException('유효한 장소 정보가 없습니다');
      }

      // bbox 정보를 SearchResultBbox로 변환
      final SearchResultBbox bbox = SearchResultBbox(
        minLon: response.data.bbox.minLon,
        minLat: response.data.bbox.minLat,
        maxLon: response.data.bbox.maxLon,
        maxLat: response.data.bbox.maxLat,
        midLon: response.data.bbox.midLon,
        midLat: response.data.bbox.midLat,
      );

      return SearchResult(query: query, places: places, bbox: bbox);
    } catch (e) {
      if (e is BaseDomainException) {
        rethrow;
      }

      throw ParsingException('검색 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  bool _isValidPlace(Place place) {
    if (place.title.trim().isEmpty) {
      return false;
    }

    if (place.address.trim().isEmpty && place.address.trim().isEmpty) {
      return false;
    }

    if (!_isValidCoordinate(place.latitude, place.longitude)) {
      return false;
    }

    return true;
  }

  // 좌표가 한국 범위 내에 있는지 확인
  bool _isValidCoordinate(double latitude, double longitude) {
    return latitude >= 33.0 &&
        latitude <= 38.5 &&
        longitude >= 124.0 &&
        longitude <= 132.0;
  }
}
