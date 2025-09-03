import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';

import '../../domain/entities/search_result.dart';
import '../../domain/repositories/place_search_repository.dart';

class PerformSubmittedSearchUseCase {
  const PerformSubmittedSearchUseCase({
    required PlaceSearchRepository repository,
  }) : _repository = repository;

  final PlaceSearchRepository _repository;

  Future<AppResult<SearchResult>> execute({
    required String query,
    required double longitude,
    required double latitude,
  }) async {
    // 검색어 validation
    if (query.trim().isEmpty) {
      return const AppFailure<SearchResult>(ValidationException('검색어를 입력해주세요'));
    }

    // API 검색 실행
    return AppSuccess<SearchResult>(
      await _repository.searchPlaces(
        query: query,
        longitude: longitude,
        latitude: latitude,
      ),
    );
  }
}
