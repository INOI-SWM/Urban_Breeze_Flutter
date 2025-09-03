import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';

import '../application/use_cases/filter_places_use_case.dart';
import '../application/use_cases/perform_realtime_search_use_case.dart';
import '../application/use_cases/perform_submitted_search_use_case.dart';
import '../application/use_cases/place_search_facade.dart';
import '../application/use_cases/process_search_results_use_case.dart';
import '../data/datasources/remote_place_search_datasource.dart';
import '../data/repositories/place_search_repository_impl.dart';
import '../domain/repositories/place_search_repository.dart';

final Provider<RemotePlaceSearchDataSource>
remotePlaceSearchDataSourceProvider = Provider<RemotePlaceSearchDataSource>((
  Ref<RemotePlaceSearchDataSource> ref,
) {
  final http.Client client = ref.watch(authorizedHttpClientProvider);

  final RemotePlaceSearchDataSource dataSource = RemotePlaceSearchDataSource(
    client: client,
  );

  return dataSource;
});

final Provider<PlaceSearchRepository> placeSearchRepositoryProvider =
    Provider<PlaceSearchRepository>((Ref<PlaceSearchRepository> ref) {
      final RemotePlaceSearchDataSource dataSource = ref.watch(
        remotePlaceSearchDataSourceProvider,
      );

      return PlaceSearchRepositoryImpl(dataSource: dataSource);
    });

final Provider<FilterPlacesUseCase> filterPlacesUseCaseProvider =
    Provider<FilterPlacesUseCase>((Ref<FilterPlacesUseCase> ref) {
      return const FilterPlacesUseCase();
    });

final Provider<ProcessSearchResultsUseCase>
processSearchResultsUseCaseProvider = Provider<ProcessSearchResultsUseCase>((
  Ref<ProcessSearchResultsUseCase> ref,
) {
  return const ProcessSearchResultsUseCase();
});

final Provider<PerformRealtimeSearchUseCase>
performRealtimeSearchUseCaseProvider = Provider<PerformRealtimeSearchUseCase>((
  Ref<PerformRealtimeSearchUseCase> ref,
) {
  final PlaceSearchRepository repository = ref.watch(
    placeSearchRepositoryProvider,
  );
  final FilterPlacesUseCase filterPlacesUseCase = ref.watch(
    filterPlacesUseCaseProvider,
  );
  final ProcessSearchResultsUseCase processResultsUseCase = ref.watch(
    processSearchResultsUseCaseProvider,
  );

  return PerformRealtimeSearchUseCase(
    repository: repository,
    filterPlacesUseCase: filterPlacesUseCase,
    processResultsUseCase: processResultsUseCase,
  );
});

final Provider<PerformSubmittedSearchUseCase>
performSubmittedSearchUseCaseProvider = Provider<PerformSubmittedSearchUseCase>(
  (Ref<PerformSubmittedSearchUseCase> ref) {
    final PlaceSearchRepository repository = ref.watch(
      placeSearchRepositoryProvider,
    );
    final ProcessSearchResultsUseCase processResultsUseCase = ref.watch(
      processSearchResultsUseCaseProvider,
    );

    return PerformSubmittedSearchUseCase(
      repository: repository,
      processResultsUseCase: processResultsUseCase,
    );
  },
);

final Provider<PlaceSearchFacade> placeSearchFacadeProvider =
    Provider<PlaceSearchFacade>((Ref<PlaceSearchFacade> ref) {
      final PerformRealtimeSearchUseCase realtimeSearchUseCase = ref.watch(
        performRealtimeSearchUseCaseProvider,
      );
      final PerformSubmittedSearchUseCase submittedSearchUseCase = ref.watch(
        performSubmittedSearchUseCaseProvider,
      );
      final FilterPlacesUseCase filterPlacesUseCase = ref.watch(
        filterPlacesUseCaseProvider,
      );
      final ProcessSearchResultsUseCase processResultsUseCase = ref.watch(
        processSearchResultsUseCaseProvider,
      );

      return PlaceSearchFacade(
        realtimeSearchUseCase: realtimeSearchUseCase,
        submittedSearchUseCase: submittedSearchUseCase,
        filterPlacesUseCase: filterPlacesUseCase,
        processResultsUseCase: processResultsUseCase,
      );
    });
