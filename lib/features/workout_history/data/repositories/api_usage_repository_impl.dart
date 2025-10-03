import 'package:urban_breeze/features/workout_history/data/datasources/api_usage_datasource.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/api_usage.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/api_usage_repository.dart';

class ApiUsageRepositoryImpl implements ApiUsageRepository {
  const ApiUsageRepositoryImpl({required this.dataSource});

  final ApiUsageDataSource dataSource;

  @override
  Future<ApiUsage> getApiUsage() async {
    return await dataSource.getApiUsage();
  }
}
