import 'package:urban_breeze/features/integration/data/datasources/provider_datasource.dart';
import 'package:urban_breeze/features/integration/domain/repositories/provider_repository.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  const ProviderRepositoryImpl({required this.dataSource});

  final ProviderDataSource dataSource;

  @override
  Future<void> deleteProvider(String providerName) async {
    return await dataSource.deleteProvider(providerName);
  }
}
