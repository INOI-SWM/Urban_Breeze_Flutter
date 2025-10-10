import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/domain/entities/api_usage.dart';
import 'package:urban_breeze/features/integration/domain/entities/provider_sync_info.dart';
import 'package:urban_breeze/features/integration/domain/enums/health_provider.dart';
import 'package:urban_breeze/features/integration/domain/repositories/api_usage_repository.dart';

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

  /// 연동된 서비스의 마지막 동기화 시간만 조회
  Future<AppResult<Map<HealthProvider, DateTime>>> executeWithLastSync() async {
    try {
      final ApiUsage apiUsage = await _apiUsageRepository.getApiUsage();
      final Map<HealthProvider, DateTime> statusMap =
          _parseActiveServicesWithLastSync(apiUsage);
      return AppSuccess<Map<HealthProvider, DateTime>>(statusMap);
    } catch (e) {
      return AppFailure<Map<HealthProvider, DateTime>>(
        NetworkException('연동 상태 조회 실패: $e'),
      );
    }
  }

  /// API 사용량 정보 조회 (토큰 체크용)
  Future<AppResult<ApiUsage>> executeWithApiUsage() async {
    try {
      final ApiUsage apiUsage = await _apiUsageRepository.getApiUsage();
      return AppSuccess<ApiUsage>(apiUsage);
    } catch (e) {
      return AppFailure<ApiUsage>(NetworkException('API 사용량 조회 실패: $e'));
    }
  }

  /// API 응답을 파싱하여 연동 상태 맵 생성
  Map<HealthProvider, bool> _parseIntegrationStatus(ApiUsage apiUsage) {
    final Map<HealthProvider, bool> statusMap = <HealthProvider, bool>{};

    for (final HealthProvider provider in HealthProvider.values) {
      statusMap[provider] = apiUsage.providerSyncInfos.any(
        (ProviderSyncInfo providerInfo) =>
            providerInfo.providerName == provider.apiProviderName &&
            providerInfo.isActive,
      );
    }

    return statusMap;
  }

  /// API 응답을 파싱하여 연동된 서비스의 마지막 동기화 시간만 반환
  Map<HealthProvider, DateTime> _parseActiveServicesWithLastSync(
    ApiUsage apiUsage,
  ) {
    final Map<HealthProvider, DateTime> statusMap =
        <HealthProvider, DateTime>{};

    for (final ProviderSyncInfo providerInfo in apiUsage.providerSyncInfos) {
      if (providerInfo.isActive) {
        // HealthProvider enum에서 해당하는 provider 찾기
        for (final HealthProvider provider in HealthProvider.values) {
          if (provider.apiProviderName == providerInfo.providerName) {
            // lastSyncAt이 null인 경우 기본값으로 30일 전 설정
            statusMap[provider] =
                providerInfo.lastSyncAt ??
                DateTime.now().subtract(const Duration(days: 30));
            break;
          }
        }
      }
    }

    return statusMap;
  }
}
