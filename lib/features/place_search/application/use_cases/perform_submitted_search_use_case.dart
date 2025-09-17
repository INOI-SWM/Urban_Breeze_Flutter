import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';

import '../../domain/entities/search_result.dart';
import '../../domain/repositories/place_search_repository.dart';
import 'process_search_results_use_case.dart';

class PerformSubmittedSearchUseCase {
  const PerformSubmittedSearchUseCase({
    required PlaceSearchRepository repository,
    required ProcessSearchResultsUseCase processResultsUseCase,
  }) : _repository = repository,
       _processResultsUseCase = processResultsUseCase;

  final PlaceSearchRepository _repository;
  final ProcessSearchResultsUseCase _processResultsUseCase;

  Future<AppResult<SearchResult>> execute({
    required String query,
    required double longitude,
    required double latitude,
  }) async {
    // 검색어 validation
    if (query.trim().isEmpty) {
      return const AppFailure<SearchResult>(
        ValidationException(code: 'SEARCH_QUERY_EMPTY'),
      );
    }

    try {
      // API 검색 실행
      final SearchResult searchResult = await _repository.searchPlaces(
        query: query,
        longitude: longitude,
        latitude: latitude,
      );

      // 검색 결과 처리 (정규화, 중복 제거 등)
      final SearchResult processedResult = _processResultsUseCase
          .processSearchResults(searchResult);
      return AppSuccess<SearchResult>(processedResult);
    } on NetworkException catch (e) {
      return AppFailure<SearchResult>(e);
    } on ValidationException catch (e) {
      return AppFailure<SearchResult>(e);
    } catch (e) {
      return AppFailure<SearchResult>(
        ServerException('검색에 실패했습니다: ${e.toString()}'),
      );
    }
  }
}
