import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/integration_authentication_repository.dart';

class GetIntegrationActivityUseCase {
  const GetIntegrationActivityUseCase({required this.repository});

  final IntegrationAuthenticationRepository repository;

  Future<AppResult<Map<String, dynamic>>> execute() async {
    try {
      final Map<String, dynamic> result =
          await repository.getIntegrationActivity();
      return AppSuccess<Map<String, dynamic>>(result);
    } catch (e) {
      return AppFailure<Map<String, dynamic>>(TerraApiException(e.toString()));
    }
  }
}
