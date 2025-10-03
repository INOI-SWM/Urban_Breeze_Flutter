import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/api_usage.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/health_provider.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/api_usage_repository.dart';

/// 연동 상태 조회 Use Case
class GetIntegrationStatusUseCase {
  const GetIntegrationStatusUseCase(this._apiUsageRepository);

  final ApiUsageRepository _apiUsageRepository;

  /// 모든 서비스의 연동 상태를 조회
  Future<AppResult<Map<HealthProvider, bool>>> execute() async {
    try {
      final ApiUsage apiUsage = await _apiUsageRepository.getApiUsage();
      final Map<HealthProvider, bool> statusMap = _parseIntegrationStatus(
        apiUsage,
      );
      return AppSuccess<Map<HealthProvider, bool>>(statusMap);
    } catch (e) {
      return AppFailure<Map<HealthProvider, bool>>(
        NetworkException('연동 상태 조회 실패: $e'),
      );
    }
  }

  /// 연동 상태와 마지막 동기화 시간을 함께 조회
  Future<AppResult<Map<HealthProvider, DateTime?>>>
  executeWithLastSync() async {
    try {
      final ApiUsage apiUsage = await _apiUsageRepository.getApiUsage();
      final Map<HealthProvider, DateTime?> statusMap =
          _parseIntegrationStatusWithLastSync(apiUsage);
      return AppSuccess<Map<HealthProvider, DateTime?>>(statusMap);
    } catch (e) {
      return AppFailure<Map<HealthProvider, DateTime?>>(
        NetworkException('연동 상태 조회 실패: $e'),
      );
    }
  }

  /// API 응답을 파싱하여 연동 상태 맵 생성
  Map<HealthProvider, bool> _parseIntegrationStatus(ApiUsage apiUsage) {
    final Map<HealthProvider, bool> statusMap = <HealthProvider, bool>{};

    for (final HealthProvider provider in HealthProvider.values) {
      statusMap[provider] = apiUsage.providerSyncInfos.any(
        (ProviderSyncInfo providerInfo) =>
            providerInfo.providerName == provider.displayName &&
            providerInfo.isActive,
      );
    }

    return statusMap;
  }

  /// API 응답을 파싱하여 연동 상태와 마지막 동기화 시간 맵 생성
  Map<HealthProvider, DateTime?> _parseIntegrationStatusWithLastSync(
    ApiUsage apiUsage,
  ) {
    final Map<HealthProvider, DateTime?> statusMap =
        <HealthProvider, DateTime?>{};

    for (final HealthProvider provider in HealthProvider.values) {
      final ProviderSyncInfo providerInfo = apiUsage.providerSyncInfos
          .firstWhere(
            (ProviderSyncInfo info) =>
                info.providerName == provider.displayName,
            orElse:
                () => ProviderSyncInfo(
                  providerName: provider.displayName,
                  lastSyncAt: null,
                  isActive: false,
                ),
          );

      if (providerInfo.isActive) {
        statusMap[provider] = providerInfo.lastSyncAt;
      } else {
        statusMap[provider] = null;
      }
    }

    return statusMap;
  }
}
