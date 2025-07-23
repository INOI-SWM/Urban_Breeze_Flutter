import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../application/use_cases/search_places_use_case.dart';
import '../data/datasources/remote_place_search_datasource.dart';
import '../data/repositories/place_search_repository_impl.dart';
import '../domain/repositories/place_search_repository.dart';

final Provider<http.Client> httpClientProvider = Provider<http.Client>((
  Ref<http.Client> ref,
) {
  final http.Client client = http.Client();
  ref.onDispose(() => client.close());
  return client;
});

final Provider<RemotePlaceSearchDataSource>
remotePlaceSearchDataSourceProvider = Provider<RemotePlaceSearchDataSource>((
  Ref<RemotePlaceSearchDataSource> ref,
) {
  final http.Client httpClient = ref.watch(httpClientProvider);

  final RemotePlaceSearchDataSource dataSource = RemotePlaceSearchDataSource(
    httpClient: httpClient,
  );

  ref.onDispose(() => dataSource.dispose());

  return dataSource;
});

final Provider<PlaceSearchRepository> placeSearchRepositoryProvider =
    Provider<PlaceSearchRepository>((Ref<PlaceSearchRepository> ref) {
      final RemotePlaceSearchDataSource dataSource = ref.watch(
        remotePlaceSearchDataSourceProvider,
      );

      return PlaceSearchRepositoryImpl(dataSource: dataSource);
    });

final Provider<SearchPlacesUseCase> searchPlacesUseCaseProvider =
    Provider<SearchPlacesUseCase>((Ref<SearchPlacesUseCase> ref) {
      final PlaceSearchRepository repository = ref.watch(
        placeSearchRepositoryProvider,
      );

      return SearchPlacesUseCase(repository: repository);
    });

final Provider<SearchPlacesUseCase> placeSearchProvider =
    searchPlacesUseCaseProvider;
