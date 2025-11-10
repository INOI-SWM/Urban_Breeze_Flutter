import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/domain/repositories/integration_repository.dart';

class GetIntegrationActivityUseCase {
  const GetIntegrationActivityUseCase({required this.repository});

  final IntegrationRepository repository;

  Future<AppResult<void>> execute() async {
    try {
      await repository.getIntegrationActivity();
      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(IntegrationException(e.toString()));
    }
  }
}
