import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/terra_repository.dart';

class InitializeTerraUseCase {
  const InitializeTerraUseCase({required this.repository});

  final TerraRepository repository;

  Future<AppResult<void>> execute() async {
    try {
      await repository.initializeTerra();
      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(IntegrationException(e.toString()));
    }
  }
}
