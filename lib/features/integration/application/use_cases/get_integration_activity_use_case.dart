import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/domain/repositories/integration_repository.dart';

class GetIntegrationActivityUseCase {
  const GetIntegrationActivityUseCase({required this.repository});

  final IntegrationRepository repository;

  Future<AppResult<Map<String, dynamic>>> execute() async {
    try {
      final Map<String, dynamic> result =
          await repository.getIntegrationActivity();
      return AppSuccess<Map<String, dynamic>>(result);
    } catch (e) {
      return AppFailure<Map<String, dynamic>>(
        IntegrationException(e.toString()),
      );
    }
  }
}
