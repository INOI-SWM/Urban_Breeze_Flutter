import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/domain/entities/integration_auth.dart';
import 'package:urban_breeze/features/integration/domain/enums/health_provider.dart';
import 'package:urban_breeze/features/integration/domain/repositories/integration_repository.dart';

class RequestWahooPermissionUseCase {
  const RequestWahooPermissionUseCase({required this.repository});

  final IntegrationRepository repository;

  Future<AppResult<IntegrationAuth>> execute() async {
    try {
      final IntegrationAuth result = await repository.requestIntegrationLink(
        terraProvider: HealthProvider.wahoo.apiProviderName,
      );
      return AppSuccess<IntegrationAuth>(result);
    } catch (e) {
      return AppFailure<IntegrationAuth>(IntegrationException(e.toString()));
    }
  }
}
