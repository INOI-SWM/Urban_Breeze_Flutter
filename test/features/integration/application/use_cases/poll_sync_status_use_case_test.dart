import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/application/use_cases/poll_sync_status_use_case.dart';
import 'package:urban_breeze/features/integration/domain/entities/sync_status.dart';
import 'package:urban_breeze/features/integration/domain/repositories/integration_repository.dart';

import 'poll_sync_status_use_case_test.mocks.dart';

@GenerateMocks(<Type>[IntegrationRepository])
void main() {
  late PollSyncStatusUseCase pollSyncStatusUseCase;
  late MockIntegrationRepository mockRepository;

  setUp(() {
    mockRepository = MockIntegrationRepository();
    pollSyncStatusUseCase = PollSyncStatusUseCase(repository: mockRepository);
  });

  group('PollSyncStatusUseCase', () {
    test(
      'execute should return SyncStatus when sync job is in progress',
      () async {
        // Arrange
        final SyncStatus expectedStatus = SyncStatus(
          jobId: 123,
          status: SyncStatusType.inProgress,
          startDate: '2025-01-01',
          endDate: '2025-01-31',
          receivedCount: 5,
          lastMessageReceivedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(
          mockRepository.getSyncStatus(),
        ).thenAnswer((_) async => expectedStatus);

        // Act
        final AppResult<SyncStatus> result =
            await pollSyncStatusUseCase.execute();

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull, expectedStatus);
        expect(result.dataOrNull?.status, SyncStatusType.inProgress);
        verify(mockRepository.getSyncStatus()).called(1);
      },
    );

    test(
      'execute should return SyncStatus when sync job is completed',
      () async {
        // Arrange
        final SyncStatus expectedStatus = SyncStatus(
          jobId: 123,
          status: SyncStatusType.completed,
          startDate: '2025-01-01',
          endDate: '2025-01-31',
          receivedCount: 10,
          lastMessageReceivedAt: DateTime.now(),
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(
          mockRepository.getSyncStatus(),
        ).thenAnswer((_) async => expectedStatus);

        // Act
        final AppResult<SyncStatus> result =
            await pollSyncStatusUseCase.execute();

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull?.status, SyncStatusType.completed);
        expect(result.dataOrNull?.completedAt, isNotNull);
        verify(mockRepository.getSyncStatus()).called(1);
      },
    );

    test(
      'execute should return SyncStatus when sync job has no activities',
      () async {
        // Arrange
        final SyncStatus expectedStatus = SyncStatus(
          jobId: 123,
          status: SyncStatusType.noActivities,
          startDate: '2025-01-01',
          endDate: '2025-01-31',
          receivedCount: 0,
          createdAt: DateTime.now(),
        );

        when(
          mockRepository.getSyncStatus(),
        ).thenAnswer((_) async => expectedStatus);

        // Act
        final AppResult<SyncStatus> result =
            await pollSyncStatusUseCase.execute();

        // Assert
        expect(result.isSuccess, true);
        expect(result.dataOrNull?.status, SyncStatusType.noActivities);
        expect(result.dataOrNull?.receivedCount, 0);
        verify(mockRepository.getSyncStatus()).called(1);
      },
    );

    test(
      'execute should return failure when sync job is not found (404)',
      () async {
        // Arrange
        when(
          mockRepository.getSyncStatus(),
        ).thenThrow(const SyncJobNotFoundException('동기화 작업을 찾을 수 없습니다.'));

        // Act
        final AppResult<SyncStatus> result =
            await pollSyncStatusUseCase.execute();

        // Assert
        expect(result.isSuccess, false);
        expect(result.exceptionOrNull, isA<SyncJobNotFoundException>());
        verify(mockRepository.getSyncStatus()).called(1);
      },
    );

    test('execute should return failure when network error occurs', () async {
      // Arrange
      when(
        mockRepository.getSyncStatus(),
      ).thenThrow(const IntegrationException('네트워크 오류'));

      // Act
      final AppResult<SyncStatus> result =
          await pollSyncStatusUseCase.execute();

      // Assert
      expect(result.isSuccess, false);
      expect(result.exceptionOrNull, isA<IntegrationException>());
      verify(mockRepository.getSyncStatus()).called(1);
    });

    test('execute should return failure when sync job has failed', () async {
      // Arrange
      final SyncStatus failedStatus = SyncStatus(
        jobId: 123,
        status: SyncStatusType.failed,
        startDate: '2025-01-01',
        endDate: '2025-01-31',
        receivedCount: 3,
        createdAt: DateTime.now(),
      );

      when(
        mockRepository.getSyncStatus(),
      ).thenAnswer((_) async => failedStatus);

      // Act
      final AppResult<SyncStatus> result =
          await pollSyncStatusUseCase.execute();

      // Assert
      expect(result.isSuccess, true);
      expect(result.dataOrNull?.status, SyncStatusType.failed);
      verify(mockRepository.getSyncStatus()).called(1);
    });
  });
}
