import 'package:terra_flutter_bridge/models/enums.dart';
import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/data/datasources/terra_api_datasoiurce.dart';

class ConnectTerraHealthAppUseCase {
  const ConnectTerraHealthAppUseCase({required this.terraDataSource});

  final TerraApiDataSource terraDataSource;

  Future<AppResult<void>> execute(Connection connection) async {
    try {
      await terraDataSource.initialiseConnection(connection);
      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(IntegrationException(e.toString()));
    }
  }
}
