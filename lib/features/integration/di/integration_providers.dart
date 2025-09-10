import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';

import '../application/facades/integration_sync_facade.dart';
import '../application/use_cases/get_integration_activity_use_case.dart';
import '../application/use_cases/request_garmin_permission_use_case.dart';
import '../application/use_cases/request_suunto_permission_use_case.dart';
import '../data/datasources/integration_datasource.dart';
import '../data/repositories/integration_repository_impl.dart';
import '../domain/repositories/integration_repository.dart';

// DataSource
final Provider<IntegrationDataSource> integrationDataSourceProvider =
    Provider<IntegrationDataSource>((Ref ref) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return IntegrationDataSource(client: client);
    });

// Repository
final Provider<IntegrationRepository> integrationRepositoryProvider =
    Provider<IntegrationRepository>((Ref ref) {
      final IntegrationDataSource dataSource = ref.watch(
        integrationDataSourceProvider,
      );
      return IntegrationRepositoryImpl(dataSource: dataSource);
    });

// Use Cases
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

final Provider<GetIntegrationActivityUseCase>
getIntegrationActivityUseCaseProvider = Provider<GetIntegrationActivityUseCase>(
  (Ref ref) {
    final IntegrationRepository repository = ref.watch(
      integrationRepositoryProvider,
    );
    return GetIntegrationActivityUseCase(repository: repository);
  },
);

// Facade
final Provider<IntegrationSyncFacade> integrationSyncFacadeProvider =
    Provider<IntegrationSyncFacade>((Ref ref) {
      final RequestGarminPermissionUseCase requestGarminPermissionUseCase = ref
          .watch(requestGarminPermissionUseCaseProvider);
      final RequestSuuntoPermissionUseCase requestSuuntoPermissionUseCase = ref
          .watch(requestSuuntoPermissionUseCaseProvider);
      final GetIntegrationActivityUseCase getIntegrationActivityUseCase = ref
          .watch(getIntegrationActivityUseCaseProvider);

      return IntegrationSyncFacade(
        requestGarminPermissionUseCase: requestGarminPermissionUseCase,
        requestSuuntoPermissionUseCase: requestSuuntoPermissionUseCase,
        getIntegrationActivityUseCase: getIntegrationActivityUseCase,
      );
    });
