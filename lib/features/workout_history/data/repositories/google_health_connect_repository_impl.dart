import '../../domain/repositories/google_health_connect_repository.dart';
import '../datasources/google_health_connect_server_datasource.dart';

class GoogleHealthConnectRepositoryImpl
    implements GoogleHealthConnectRepository {
  const GoogleHealthConnectRepositoryImpl({required this.dataSource});

  final GoogleHealthConnectServerDataSource dataSource;

  @override
  Future<void> connectGoogleHealthConnect() async {
    await dataSource.connectGoogleHealthConnect();
  }
}
