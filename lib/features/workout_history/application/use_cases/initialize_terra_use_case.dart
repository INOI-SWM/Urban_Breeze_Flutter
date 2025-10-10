import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/data/datasources/terra_api_datasoiurce.dart';

class InitializeTerraUseCase {
  const InitializeTerraUseCase({required this.terraDataSource});

  final TerraApiDataSource terraDataSource;

  Future<AppResult<void>> execute() async {
    try {
      await terraDataSource.initTerra();
      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(IntegrationException(e.toString()));
    }
  }
}
