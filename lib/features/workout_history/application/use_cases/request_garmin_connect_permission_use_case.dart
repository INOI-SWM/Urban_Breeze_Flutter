import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/data/datasources/integration_authentication_datasource.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';

class RequestGarminConnectPermissionUseCase {
  const RequestGarminConnectPermissionUseCase({
    required this.integrationDataSource,
  });

  final IntegrationAuthenticationDataSource integrationDataSource;

  Future<AppResult<Map<String, dynamic>>> execute() async {
    try {
      final Map<String, dynamic> result = await integrationDataSource
          .requestIntegrationLink(terraProvider: 'GARMIN');
      return AppSuccess<Map<String, dynamic>>(result);
    } catch (e) {
      return AppFailure<Map<String, dynamic>>(TerraApiException(e.toString()));
    }
  }
}
