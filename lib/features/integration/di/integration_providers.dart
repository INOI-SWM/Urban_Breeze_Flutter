import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';

import '../application/facades/integration_sync_facade.dart';
import '../application/use_cases/delete_provider_use_case.dart';
import '../application/use_cases/get_api_usage_use_case.dart';
import '../application/use_cases/get_integration_activity_use_case.dart';
import '../application/use_cases/get_integration_status_use_case.dart';
import '../application/use_cases/request_garmin_permission_use_case.dart';
import '../application/use_cases/request_suunto_permission_use_case.dart';
import '../application/use_cases/request_wahoo_permission_use_case.dart';
import '../data/datasources/api_usage_datasource.dart';
import '../data/datasources/integration_datasource.dart';
import '../data/datasources/provider_datasource.dart';
import '../data/repositories/api_usage_repository_impl.dart';
import '../data/repositories/integration_repository_impl.dart';
import '../data/repositories/provider_repository_impl.dart';
import '../domain/repositories/api_usage_repository.dart';
import '../domain/repositories/integration_repository.dart';
import '../domain/repositories/provider_repository.dart';

// ============================================
// DataSources
// ============================================

final Provider<IntegrationDataSource> integrationDataSourceProvider =
    Provider<IntegrationDataSource>((Ref ref) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return IntegrationDataSource(client: client);
    });

final Provider<ApiUsageDataSource> apiUsageDataSourceProvider =
    Provider<ApiUsageDataSource>((Ref ref) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return ApiUsageDataSource(client: client);
    });

final Provider<ProviderDataSource> providerDataSourceProvider =
    Provider<ProviderDataSource>((Ref ref) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return ProviderDataSource(client: client);
    });

// ============================================
// Repositories
// ============================================

final Provider<IntegrationRepository> integrationRepositoryProvider =
    Provider<IntegrationRepository>((Ref ref) {
      final IntegrationDataSource dataSource = ref.watch(
        integrationDataSourceProvider,
      );
      return IntegrationRepositoryImpl(dataSource: dataSource);
    });

final Provider<ApiUsageRepository> apiUsageRepositoryProvider =
    Provider<ApiUsageRepository>((Ref ref) {
      final ApiUsageDataSource dataSource = ref.watch(
        apiUsageDataSourceProvider,
      );
      return ApiUsageRepositoryImpl(dataSource: dataSource);
    });

final Provider<ProviderRepository> providerRepositoryProvider =
    Provider<ProviderRepository>((Ref ref) {
      final ProviderDataSource dataSource = ref.watch(
        providerDataSourceProvider,
      );
      return ProviderRepositoryImpl(dataSource: dataSource);
    });

// ============================================
// Use Cases
// ============================================

final Provider<RequestGarminPermissionUseCase>
requestGarminPermissionUseCaseProvider =
    Provider<RequestGarminPermissionUseCase>((Ref ref) {
      final IntegrationRepository repository = ref.watch(
        integrationRepositoryProvider,
      );
      return RequestGarminPermissionUseCase(repository: repository);
    });

final Provider<RequestSuuntoPermissionUseCase>
requestSuuntoPermissionUseCaseProvider =
    Provider<RequestSuuntoPermissionUseCase>((Ref ref) {
      final IntegrationRepository repository = ref.watch(
        integrationRepositoryProvider,
      );
      return RequestSuuntoPermissionUseCase(repository: repository);
    });

final Provider<RequestWahooPermissionUseCase>
requestWahooPermissionUseCaseProvider = Provider<RequestWahooPermissionUseCase>(
  (Ref ref) {
    final IntegrationRepository repository = ref.watch(
      integrationRepositoryProvider,
    );
    return RequestWahooPermissionUseCase(repository: repository);
  },
);

final Provider<GetIntegrationActivityUseCase>
getIntegrationActivityUseCaseProvider = Provider<GetIntegrationActivityUseCase>(
  (Ref ref) {
    final IntegrationRepository repository = ref.watch(
      integrationRepositoryProvider,
    );
    return GetIntegrationActivityUseCase(repository: repository);
  },
);

final Provider<GetIntegrationStatusUseCase>
getIntegrationStatusUseCaseProvider = Provider<GetIntegrationStatusUseCase>((
  Ref ref,
) {
  final ApiUsageRepository repository = ref.watch(apiUsageRepositoryProvider);
  return GetIntegrationStatusUseCase(repository);
});

final Provider<GetApiUsageUseCase> getApiUsageUseCaseProvider =
    Provider<GetApiUsageUseCase>((Ref ref) {
      final ApiUsageRepository repository = ref.watch(
        apiUsageRepositoryProvider,
      );
      return GetApiUsageUseCase(repository: repository);
    });

final Provider<DeleteProviderUseCase> deleteProviderUseCaseProvider =
    Provider<DeleteProviderUseCase>((Ref ref) {
      final ProviderRepository repository = ref.watch(
        providerRepositoryProvider,
      );
      return DeleteProviderUseCase(repository: repository);
    });

// ============================================
// Facade
// ============================================

final Provider<IntegrationSyncFacade> integrationSyncFacadeProvider =
    Provider<IntegrationSyncFacade>((Ref ref) {
      final RequestGarminPermissionUseCase requestGarminPermissionUseCase = ref
          .watch(requestGarminPermissionUseCaseProvider);
      final RequestSuuntoPermissionUseCase requestSuuntoPermissionUseCase = ref
          .watch(requestSuuntoPermissionUseCaseProvider);
      final RequestWahooPermissionUseCase requestWahooPermissionUseCase = ref
          .watch(requestWahooPermissionUseCaseProvider);
      final GetIntegrationActivityUseCase getIntegrationActivityUseCase = ref
          .watch(getIntegrationActivityUseCaseProvider);

      return IntegrationSyncFacade(
        requestGarminPermissionUseCase: requestGarminPermissionUseCase,
        requestSuuntoPermissionUseCase: requestSuuntoPermissionUseCase,
        requestWahooPermissionUseCase: requestWahooPermissionUseCase,
        getIntegrationActivityUseCase: getIntegrationActivityUseCase,
      );
    });
