import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/integration_authentication.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/integration_authentication_repository.dart';

class RequestGarminConnectPermissionUseCase {
  const RequestGarminConnectPermissionUseCase({required this.repository});

  final IntegrationAuthenticationRepository repository;

  Future<AppResult<IntegrationAuthentication>> execute() async {
    try {
      final IntegrationAuthentication result = await repository
          .requestIntegrationLink(terraProvider: 'GARMIN');
      return AppSuccess<IntegrationAuthentication>(result);
    } catch (e) {
      return AppFailure<IntegrationAuthentication>(
        TerraApiException(e.toString()),
      );
    }
  }
}
