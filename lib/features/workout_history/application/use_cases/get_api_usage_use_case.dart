import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/api_usage.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/api_usage_repository.dart';

class GetApiUsageUseCase {
  const GetApiUsageUseCase({required this.repository});

  final ApiUsageRepository repository;

  Future<AppResult<ApiUsage>> execute() async {
    try {
      final ApiUsage apiUsage = await repository.getApiUsage();
      return AppSuccess<ApiUsage>(apiUsage);
    } catch (e) {
      return AppFailure<ApiUsage>(NetworkException(e.toString()));
    }
  }
}
