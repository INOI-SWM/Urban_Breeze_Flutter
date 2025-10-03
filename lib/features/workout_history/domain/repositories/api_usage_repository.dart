import 'package:urban_breeze/features/workout_history/domain/entities/api_usage.dart';

abstract class ApiUsageRepository {
  Future<ApiUsage> getApiUsage();
}
