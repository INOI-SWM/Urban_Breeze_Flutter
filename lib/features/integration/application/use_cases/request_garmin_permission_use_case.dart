import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/domain/entities/integration_auth.dart';
import 'package:urban_breeze/features/integration/domain/repositories/integration_repository.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';

class RequestGarminPermissionUseCase {
  const RequestGarminPermissionUseCase({required this.repository});

  final IntegrationRepository repository;

  Future<AppResult<IntegrationAuth>> execute() async {
    try {
      final IntegrationAuth result = await repository.requestIntegrationLink(
        terraProvider: 'GARMIN',
      );
      return AppSuccess<IntegrationAuth>(result);
    } catch (e) {
      return AppFailure<IntegrationAuth>(TerraApiException(e.toString()));
    }
  }
}
