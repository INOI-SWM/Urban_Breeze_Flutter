import 'package:urban_breeze/features/integration/domain/entities/api_usage.dart';

abstract class ApiUsageRepository {
  Future<ApiUsage> getApiUsage();
}
