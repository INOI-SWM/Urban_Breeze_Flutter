import 'package:urban_breeze/features/workout_history/data/datasources/apple_health_connect_datasource.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/apple_health_connection.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/apple_health_connect_repository.dart';

class AppleHealthConnectRepositoryImpl implements AppleHealthConnectRepository {
  const AppleHealthConnectRepositoryImpl({required this.dataSource});

  final AppleHealthConnectDataSource dataSource;

  @override
  Future<AppleHealthConnection> connectAppleHealth() async {
    return await dataSource.connectAppleHealth();
  }
}
