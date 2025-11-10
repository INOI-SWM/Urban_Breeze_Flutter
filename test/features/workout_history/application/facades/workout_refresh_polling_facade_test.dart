import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:urban_breeze/core/exceptions/integration_exceptions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/integration/application/use_cases/get_integration_activity_use_case.dart';
import 'package:urban_breeze/features/integration/application/use_cases/poll_sync_status_use_case.dart';
import 'package:urban_breeze/features/integration/domain/entities/sync_status.dart';
import 'package:urban_breeze/features/workout_history/application/facades/workout_refresh_polling_facade.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/selective_sync_use_case.dart';

import 'workout_refresh_polling_facade_test.mocks.dart';

@GenerateMocks(<Type>[
  SelectiveSyncUseCase,
  PollSyncStatusUseCase,
  GetIntegrationActivityUseCase,
])
void main() {
  late WorkoutRefreshPollingFacade facade;
  late MockSelectiveSyncUseCase mockSelectiveSyncUseCase;
  late MockPollSyncStatusUseCase mockPollSyncStatusUseCase;
  late MockGetIntegrationActivityUseCase mockGetIntegrationActivityUseCase;

  setUpAll(() {
    // Mockito에게 AppResult의 더미 값 제공
    provideDummy<AppResult<Map<String, dynamic>?>>(
      const AppSuccess<Map<String, dynamic>?>(null),
    );
    provideDummy<AppResult<SyncStatus>>(
      AppSuccess<SyncStatus>(
        SyncStatus(
          jobId: 0,
          status: SyncStatusType.inProgress,
          startDate: '',
          endDate: '',
          receivedCount: 0,
          createdAt: DateTime.now(),
        ),
      ),
    );
    provideDummy<AppResult<void>>(const AppSuccess<void>(null));
  });

  setUp(() {
    mockSelectiveSyncUseCase = MockSelectiveSyncUseCase();
    mockPollSyncStatusUseCase = MockPollSyncStatusUseCase();
    mockGetIntegrationActivityUseCase = MockGetIntegrationActivityUseCase();

    // 기본 stub: GetIntegrationActivity는 성공 응답
    when(
      mockGetIntegrationActivityUseCase.execute(),
    ).thenAnswer((_) async => const AppSuccess<void>(null));

    facade = WorkoutRefreshPollingFacade(
      selectiveSyncUseCase: mockSelectiveSyncUseCase,
      pollSyncStatusUseCase: mockPollSyncStatusUseCase,
      getIntegrationActivityUseCase: mockGetIntegrationActivityUseCase,
    );
  });

  group('WorkoutRefreshPollingFacade', () {
    test(
      'performRefreshWithPolling should start polling after initial sync success',
      () async {
        // Arrange
        final Map<String, dynamic> initialSyncData = <String, dynamic>{
          'success': true,
          'message': 'Sync started',
        };

        final SyncStatus inProgressStatus = SyncStatus(
          jobId: 123,
          status: SyncStatusType.inProgress,
          startDate: '2025-01-01',
          endDate: '2025-01-31',
          receivedCount: 5,
          lastMessageReceivedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(mockSelectiveSyncUseCase.execute()).thenAnswer(
          (_) async => AppSuccess<Map<String, dynamic>?>(initialSyncData),
        );

        when(
          mockPollSyncStatusUseCase.execute(),
        ).thenAnswer((_) async => AppSuccess<SyncStatus>(inProgressStatus));

        // Act
        final Stream<SyncPollingState> stream =
            facade.performRefreshWithPolling();
        final List<SyncPollingState> states = <SyncPollingState>[];

        // 초기 상태 수집
        await for (final SyncPollingState state in stream.take(2)) {
          states.add(state);
        }

        // Assert
        expect(states.first.isPolling, true);
        expect(states.first.currentStatus, isNull);
        verify(mockSelectiveSyncUseCase.execute()).called(1);
      },
    );

    test(
      'performRefreshWithPolling should emit completed state when sync finishes',
      () async {
        // Arrange
        final Map<String, dynamic> initialSyncData = <String, dynamic>{
          'success': true,
          'message': 'Sync started',
        };

        final SyncStatus completedStatus = SyncStatus(
          jobId: 123,
          status: SyncStatusType.completed,
          startDate: '2025-01-01',
          endDate: '2025-01-31',
          receivedCount: 10,
          lastMessageReceivedAt: DateTime.now(),
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(mockSelectiveSyncUseCase.execute()).thenAnswer(
          (_) async => AppSuccess<Map<String, dynamic>?>(initialSyncData),
        );

        when(
          mockPollSyncStatusUseCase.execute(),
        ).thenAnswer((_) async => AppSuccess<SyncStatus>(completedStatus));

        // Act
        final Stream<SyncPollingState> stream =
            facade.performRefreshWithPolling();
        final List<SyncPollingState> states = <SyncPollingState>[];

        await for (final SyncPollingState state in stream) {
          states.add(state);
          if (state.currentStatus?.isCompleted ?? false) {
            break;
          }
        }

        // Assert
        expect(states.last.isPolling, false);
        expect(states.last.currentStatus?.status, SyncStatusType.completed);
        expect(states.last.errorMessage, isNull);
      },
    );

    test(
      'performRefreshWithPolling should emit noActivities state when no records found',
      () async {
        // Arrange
        final Map<String, dynamic> initialSyncData = <String, dynamic>{
          'success': true,
          'message': 'Sync started',
        };

        final SyncStatus noActivitiesStatus = SyncStatus(
          jobId: 123,
          status: SyncStatusType.noActivities,
          startDate: '2025-01-01',
          endDate: '2025-01-31',
          receivedCount: 0,
          createdAt: DateTime.now(),
        );

        when(mockSelectiveSyncUseCase.execute()).thenAnswer(
          (_) async => AppSuccess<Map<String, dynamic>?>(initialSyncData),
        );

        when(
          mockPollSyncStatusUseCase.execute(),
        ).thenAnswer((_) async => AppSuccess<SyncStatus>(noActivitiesStatus));

        // Act
        final Stream<SyncPollingState> stream =
            facade.performRefreshWithPolling();
        final List<SyncPollingState> states = <SyncPollingState>[];

        await for (final SyncPollingState state in stream) {
          states.add(state);
          if (state.currentStatus?.isNoActivities ?? false) {
            break;
          }
        }

        // Assert
        expect(states.last.isPolling, false);
        expect(states.last.currentStatus?.status, SyncStatusType.noActivities);
        expect(states.last.currentStatus?.receivedCount, 0);
      },
    );

    test(
      'performRefreshWithPolling should emit error state when initial sync fails',
      () async {
        // Arrange
        when(mockSelectiveSyncUseCase.execute()).thenAnswer(
          (_) async => const AppFailure<Map<String, dynamic>?>(
            IntegrationException('동기화 실패'),
          ),
        );

        // Act
        final Stream<SyncPollingState> stream =
            facade.performRefreshWithPolling();
        final List<SyncPollingState> states = <SyncPollingState>[];

        await for (final SyncPollingState state in stream) {
          states.add(state);
          if (state.errorMessage != null) {
            break;
          }
        }

        // Assert
        expect(states.last.isPolling, false);
        expect(states.last.errorMessage, isNotNull);
        expect(states.last.errorMessage, contains('동기화 실패'));
        verify(mockSelectiveSyncUseCase.execute()).called(1);
        verifyNever(mockPollSyncStatusUseCase.execute());
      },
    );

    test(
      'performRefreshWithPolling should stop polling when sync job not found (404)',
      () async {
        // Arrange: 404는 동기화 작업이 생성되지 않았다는 의미로 즉시 종료
        final Map<String, dynamic> initialSyncData = <String, dynamic>{
          'success': true,
          'message': 'Sync started',
        };

        when(mockSelectiveSyncUseCase.execute()).thenAnswer(
          (_) async => AppSuccess<Map<String, dynamic>?>(initialSyncData),
        );

        // 404 에러 반환
        when(mockPollSyncStatusUseCase.execute()).thenAnswer(
          (_) async => const AppFailure<SyncStatus>(
            SyncJobNotFoundException('동기화 작업을 찾을 수 없습니다.'),
          ),
        );

        // Act
        final Stream<SyncPollingState> stream =
            facade.performRefreshWithPolling();
        final List<SyncPollingState> states = <SyncPollingState>[];

        await for (final SyncPollingState state in stream) {
          states.add(state);
        }

        // Assert: 404 발생 시 NO_ACTIVITIES 상태로 즉시 종료
        expect(states.last.isPolling, false);
        expect(states.last.currentStatus?.status, SyncStatusType.noActivities);
        verify(mockPollSyncStatusUseCase.execute()).called(1); // 1번만 호출
      },
    );

    test(
      'performRefreshWithPolling should emit failed state when sync fails',
      () async {
        // Arrange
        final Map<String, dynamic> initialSyncData = <String, dynamic>{
          'success': true,
          'message': 'Sync started',
        };

        final SyncStatus failedStatus = SyncStatus(
          jobId: 123,
          status: SyncStatusType.failed,
          startDate: '2025-01-01',
          endDate: '2025-01-31',
          receivedCount: 3,
          createdAt: DateTime.now(),
        );

        when(mockSelectiveSyncUseCase.execute()).thenAnswer(
          (_) async => AppSuccess<Map<String, dynamic>?>(initialSyncData),
        );

        when(
          mockPollSyncStatusUseCase.execute(),
        ).thenAnswer((_) async => AppSuccess<SyncStatus>(failedStatus));

        // Act
        final Stream<SyncPollingState> stream =
            facade.performRefreshWithPolling();
        final List<SyncPollingState> states = <SyncPollingState>[];

        await for (final SyncPollingState state in stream) {
          states.add(state);
          if (state.currentStatus?.isFailed ?? false) {
            break;
          }
        }

        // Assert
        expect(states.last.isPolling, false);
        expect(states.last.currentStatus?.status, SyncStatusType.failed);
      },
    );

    test(
      'performRefreshWithPolling should continue polling while status is IN_PROGRESS',
      () async {
        // Arrange
        final Map<String, dynamic> initialSyncData = <String, dynamic>{
          'success': true,
          'message': 'Sync started',
        };

        final SyncStatus inProgressStatus1 = SyncStatus(
          jobId: 123,
          status: SyncStatusType.inProgress,
          startDate: '2025-01-01',
          endDate: '2025-01-31',
          receivedCount: 5,
          lastMessageReceivedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(mockSelectiveSyncUseCase.execute()).thenAnswer(
          (_) async => AppSuccess<Map<String, dynamic>?>(initialSyncData),
        );

        when(
          mockPollSyncStatusUseCase.execute(),
        ).thenAnswer((_) async => AppSuccess<SyncStatus>(inProgressStatus1));

        // Act
        final Stream<SyncPollingState> stream =
            facade.performRefreshWithPolling();
        final List<SyncPollingState> states = <SyncPollingState>[];

        // 처음 3개의 상태만 수집 (초기 + 폴링 2회)
        await for (final SyncPollingState state in stream.take(3)) {
          states.add(state);
        }

        // Assert
        expect(states.length, 3);
        expect(states[0].isPolling, true);
        expect(states[1].currentStatus?.status, SyncStatusType.inProgress);
        expect(states[1].currentStatus?.receivedCount, 5);
      },
    );

    test(
      'performRefreshWithPolling should skip polling for Apple HealthKit only sync',
      () async {
        // Arrange: Apple HealthKit만 동기화 (원격 없음)
        final Map<String, dynamic> initialSyncData = <String, dynamic>{
          'source': 'apple_health_kit',
          'hasRemoteIntegration': false,
          'totalSuccess': 5,
        };

        when(mockSelectiveSyncUseCase.execute()).thenAnswer(
          (_) async => AppSuccess<Map<String, dynamic>?>(initialSyncData),
        );

        // Act
        final Stream<SyncPollingState> stream =
            facade.performRefreshWithPolling();
        final List<SyncPollingState> states = <SyncPollingState>[];

        await for (final SyncPollingState state in stream) {
          states.add(state);
        }

        // Assert
        expect(states.length, 2); // 초기 + 완료 상태만
        expect(states.first.isPolling, true); // 초기 로딩
        expect(states.last.isPolling, false); // 즉시 완료
        expect(states.last.currentStatus?.status, SyncStatusType.completed);
        expect(states.last.currentStatus?.receivedCount, 5);

        // 폴링 API 호출되지 않음 확인
        verifyNever(mockPollSyncStatusUseCase.execute());
      },
    );

    test(
      'performRefreshWithPolling should poll for Apple HealthKit + remote sync',
      () async {
        // Arrange: Apple HealthKit + 원격(Garmin 등) 동기화
        final Map<String, dynamic> initialSyncData = <String, dynamic>{
          'source': 'apple_health_kit',
          'hasRemoteIntegration': true, // 원격 동기화 있음!
          'totalSuccess': 5,
        };

        final SyncStatus completedStatus = SyncStatus(
          jobId: 123,
          status: SyncStatusType.completed,
          startDate: '2025-01-01',
          endDate: '2025-01-31',
          receivedCount: 10,
          completedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        when(mockSelectiveSyncUseCase.execute()).thenAnswer(
          (_) async => AppSuccess<Map<String, dynamic>?>(initialSyncData),
        );

        when(
          mockPollSyncStatusUseCase.execute(),
        ).thenAnswer((_) async => AppSuccess<SyncStatus>(completedStatus));

        // Act
        final Stream<SyncPollingState> stream =
            facade.performRefreshWithPolling();
        final List<SyncPollingState> states = <SyncPollingState>[];

        await for (final SyncPollingState state in stream) {
          states.add(state);
          if (state.currentStatus?.isCompleted ?? false) {
            break;
          }
        }

        // Assert
        expect(states.last.isPolling, false);
        expect(states.last.currentStatus?.status, SyncStatusType.completed);

        // 폴링 API 호출됨 확인
        verify(mockPollSyncStatusUseCase.execute()).called(greaterThan(0));
      },
    );
  });
}
