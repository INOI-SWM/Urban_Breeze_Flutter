import 'package:terra_flutter_bridge/models/enums.dart';
import 'package:urban_breeze/features/workout_history/data/datasources/terra_api_datasoiurce.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/terra_repository.dart';

class TerraRepositoryImpl implements TerraRepository {
  const TerraRepositoryImpl({required this.dataSource});

  final TerraApiDataSource dataSource;

  @override
  Future<void> initializeTerra() async {
    await dataSource.initTerra();
  }

  @override
  Future<void> connectHealthApp(Connection connection) async {
    await dataSource.initialiseConnection(connection);
  }

  @override
  Future<Map<String, dynamic>?> getHealthData({
    required Connection connection,
    required DateTime startDate,
    required DateTime endDate,
    bool toWebhook = true,
  }) async {
    return await dataSource.getData(
      connection,
      startDate: startDate,
      endDate: endDate,
      toWebhook: toWebhook,
    );
  }
}
