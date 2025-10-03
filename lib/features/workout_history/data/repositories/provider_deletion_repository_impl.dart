import 'package:urban_breeze/features/workout_history/data/datasources/provider_deletion_datasource.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/provider_deletion_repository.dart';

class ProviderDeletionRepositoryImpl implements ProviderDeletionRepository {
  const ProviderDeletionRepositoryImpl({required this.dataSource});

  final ProviderDeletionDataSource dataSource;

  @override
  Future<void> deleteProvider(String providerName) async {
    return await dataSource.deleteProvider(providerName);
  }
}
