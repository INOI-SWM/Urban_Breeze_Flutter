import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/domain/repositories/integration_repository.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';

class GetIntegrationActivityUseCase {
  const GetIntegrationActivityUseCase({required this.repository});

  final IntegrationRepository repository;

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
