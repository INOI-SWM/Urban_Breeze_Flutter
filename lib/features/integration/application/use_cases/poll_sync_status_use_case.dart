import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/domain/entities/sync_status.dart';
import 'package:urban_breeze/features/integration/domain/repositories/integration_repository.dart';

/// Terra 동기화 상태 폴링 Use Case
class PollSyncStatusUseCase {
  const PollSyncStatusUseCase({required this.repository});

  final IntegrationRepository repository;

  /// 동기화 상태 조회
  Future<AppResult<SyncStatus>> execute() async {
    try {
      final SyncStatus syncStatus = await repository.getSyncStatus();
      return AppSuccess<SyncStatus>(syncStatus);
    } on SyncJobNotFoundException catch (e) {
      return AppFailure<SyncStatus>(e);
    } on IntegrationException catch (e) {
      return AppFailure<SyncStatus>(e);
    } catch (e) {
      return AppFailure<SyncStatus>(IntegrationException('동기화 상태 조회 실패: $e'));
    }
  }
}
