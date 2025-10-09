import 'package:terra_flutter_bridge/models/enums.dart';
import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/data/datasources/terra_api_datasoiurce.dart';

class SyncTerraHealthDataUseCase {
  const SyncTerraHealthDataUseCase({required this.terraDataSource});

  final TerraApiDataSource terraDataSource;

  Future<AppResult<Map<String, dynamic>?>> execute({
    required Connection connection,
    required DateTime startDate,
    required DateTime endDate,
    bool toWebhook = true,
  }) async {
    try {
      final Map<String, dynamic>? result = await terraDataSource.getData(
        connection,
        startDate: startDate,
        endDate: endDate,
        toWebhook: toWebhook,
      );
      return AppSuccess<Map<String, dynamic>?>(result);
    } catch (e) {
      return AppFailure<Map<String, dynamic>?>(
        IntegrationException(e.toString()),
      );
    }
  }
}
