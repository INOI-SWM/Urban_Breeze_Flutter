import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';

import '../../domain/entities/search_result.dart';
import 'filter_places_use_case.dart';
import 'perform_realtime_search_use_case.dart';
import 'perform_submitted_search_use_case.dart';
import 'process_search_results_use_case.dart';

class PlaceSearchFacade {
  const PlaceSearchFacade({
    required PerformRealtimeSearchUseCase realtimeSearchUseCase,
    required PerformSubmittedSearchUseCase submittedSearchUseCase,
    required FilterPlacesUseCase filterPlacesUseCase,
    required ProcessSearchResultsUseCase processResultsUseCase,
  }) : _realtimeSearchUseCase = realtimeSearchUseCase,
       _submittedSearchUseCase = submittedSearchUseCase,
       _filterPlacesUseCase = filterPlacesUseCase,
       _processResultsUseCase = processResultsUseCase;

  final PerformRealtimeSearchUseCase _realtimeSearchUseCase;
  final PerformSubmittedSearchUseCase _submittedSearchUseCase;
  final FilterPlacesUseCase _filterPlacesUseCase;
  final ProcessSearchResultsUseCase _processResultsUseCase;

  // Getter 패턴 (RoutePlanningFacade 스타일)
  PerformRealtimeSearchUseCase get realtimeSearch => _realtimeSearchUseCase;
  PerformSubmittedSearchUseCase get submittedSearch => _submittedSearchUseCase;
  FilterPlacesUseCase get filterPlaces => _filterPlacesUseCase;
  ProcessSearchResultsUseCase get processResults => _processResultsUseCase;

  /// 실시간 검색 (기존 결과 필터링 포함)
  Future<AppResult<SearchResult>> performRealtimeSearch({
    required String query,
    required double longitude,
    required double latitude,
    SearchResult? lastSearchResult,
  }) async {
    try {
      return await _realtimeSearchUseCase.execute(
        query: query,
        longitude: longitude,
        latitude: latitude,
        lastSearchResult: lastSearchResult,
      );
    } on NetworkException catch (e) {
      return AppFailure<SearchResult>(e);
    } on ValidationException catch (e) {
      return AppFailure<SearchResult>(e);
    } catch (e) {
      return AppFailure<SearchResult>(
        ServerException('실시간 검색 중 오류가 발생했습니다: ${e.toString()}'),
      );
    }
  }

  /// RETURN 검색 (새로운 검색만)
  Future<AppResult<SearchResult>> performSubmittedSearch({
    required String query,
    required double longitude,
    required double latitude,
  }) async {
    try {
      return await _submittedSearchUseCase.execute(
        query: query,
        longitude: longitude,
        latitude: latitude,
      );
    } on NetworkException catch (e) {
      return AppFailure<SearchResult>(e);
    } on ValidationException catch (e) {
      return AppFailure<SearchResult>(e);
    } catch (e) {
      return AppFailure<SearchResult>(
        ServerException('검색 중 오류가 발생했습니다: ${e.toString()}'),
      );
    }
  }
}
