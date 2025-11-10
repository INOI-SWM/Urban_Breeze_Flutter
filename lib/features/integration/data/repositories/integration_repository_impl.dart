import 'package:urban_breeze/features/integration/data/datasources/integration_datasource.dart';
import 'package:urban_breeze/features/integration/data/mappers/integration_mapper.dart';
import 'package:urban_breeze/features/integration/data/models/integration_response_model.dart';
import 'package:urban_breeze/features/integration/domain/entities/integration_auth.dart';
import 'package:urban_breeze/features/integration/domain/entities/sync_status.dart';
import 'package:urban_breeze/features/integration/domain/repositories/integration_repository.dart';

/// 연동 Repository 구현체
class IntegrationRepositoryImpl implements IntegrationRepository {
  const IntegrationRepositoryImpl({required this.dataSource});

  final IntegrationDataSource dataSource;

  @override
  Future<IntegrationAuth> requestIntegrationLink({
    required String terraProvider,
  }) async {
    final IntegrationApiResponse response = await dataSource
        .requestIntegrationLink(terraProvider: terraProvider);
    return IntegrationMapper.fromResponseModel(response.data);
  }

  @override
  Future<void> getIntegrationActivity() async {
    await dataSource.getIntegrationActivity();
  }

  @override
  Future<SyncStatus> getSyncStatus() async {
    return await dataSource.getSyncStatus();
  }
}
