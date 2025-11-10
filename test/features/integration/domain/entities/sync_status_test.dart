import 'package:flutter_test/flutter_test.dart';
import 'package:urban_breeze/features/integration/domain/entities/sync_status.dart';

void main() {
  group('SyncStatus Entity', () {
    test('SyncStatus.fromJson should parse IN_PROGRESS status correctly', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'jobId': 123,
        'status': 'IN_PROGRESS',
        'startDate': '2025-01-01',
        'endDate': '2025-01-31',
        'receivedCount': 5,
        'lastMessageReceivedAt': '2025-01-15T10:30:00',
        'completedAt': null,
        'createdAt': '2025-01-15T10:00:00',
      };

      // Act
      final SyncStatus syncStatus = SyncStatus.fromJson(json);

      // Assert
      expect(syncStatus.jobId, 123);
      expect(syncStatus.status, SyncStatusType.inProgress);
      expect(syncStatus.startDate, '2025-01-01');
      expect(syncStatus.endDate, '2025-01-31');
      expect(syncStatus.receivedCount, 5);
      expect(syncStatus.lastMessageReceivedAt, isNotNull);
      expect(syncStatus.completedAt, isNull);
      expect(syncStatus.createdAt, isNotNull);
    });

    test('SyncStatus.fromJson should parse COMPLETED status correctly', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'jobId': 123,
        'status': 'COMPLETED',
        'startDate': '2025-01-01',
        'endDate': '2025-01-31',
        'receivedCount': 10,
        'lastMessageReceivedAt': '2025-01-15T10:30:00',
        'completedAt': '2025-01-15T10:35:00',
        'createdAt': '2025-01-15T10:00:00',
      };

      // Act
      final SyncStatus syncStatus = SyncStatus.fromJson(json);

      // Assert
      expect(syncStatus.status, SyncStatusType.completed);
      expect(syncStatus.receivedCount, 10);
      expect(syncStatus.completedAt, isNotNull);
    });

    test('SyncStatus.fromJson should parse NO_ACTIVITIES status correctly', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'jobId': 123,
        'status': 'NO_ACTIVITIES',
        'startDate': '2025-01-01',
        'endDate': '2025-01-31',
        'receivedCount': 0,
        'lastMessageReceivedAt': null,
        'completedAt': null,
        'createdAt': '2025-01-15T10:00:00',
      };

      // Act
      final SyncStatus syncStatus = SyncStatus.fromJson(json);

      // Assert
      expect(syncStatus.status, SyncStatusType.noActivities);
      expect(syncStatus.receivedCount, 0);
      expect(syncStatus.lastMessageReceivedAt, isNull);
    });

    test('SyncStatus.fromJson should parse FAILED status correctly', () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        'jobId': 123,
        'status': 'FAILED',
        'startDate': '2025-01-01',
        'endDate': '2025-01-31',
        'receivedCount': 3,
        'lastMessageReceivedAt': '2025-01-15T10:30:00',
        'completedAt': null,
        'createdAt': '2025-01-15T10:00:00',
      };

      // Act
      final SyncStatus syncStatus = SyncStatus.fromJson(json);

      // Assert
      expect(syncStatus.status, SyncStatusType.failed);
      expect(syncStatus.receivedCount, 3);
    });

    test('SyncStatus should handle isInProgress getter correctly', () {
      // Arrange
      final SyncStatus inProgressStatus = SyncStatus(
        jobId: 123,
        status: SyncStatusType.inProgress,
        startDate: '2025-01-01',
        endDate: '2025-01-31',
        receivedCount: 5,
        createdAt: DateTime.now(),
      );

      final SyncStatus completedStatus = SyncStatus(
        jobId: 123,
        status: SyncStatusType.completed,
        startDate: '2025-01-01',
        endDate: '2025-01-31',
        receivedCount: 10,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(inProgressStatus.isInProgress, true);
      expect(completedStatus.isInProgress, false);
    });

    test('SyncStatus should handle isCompleted getter correctly', () {
      // Arrange
      final SyncStatus completedStatus = SyncStatus(
        jobId: 123,
        status: SyncStatusType.completed,
        startDate: '2025-01-01',
        endDate: '2025-01-31',
        receivedCount: 10,
        createdAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      final SyncStatus inProgressStatus = SyncStatus(
        jobId: 123,
        status: SyncStatusType.inProgress,
        startDate: '2025-01-01',
        endDate: '2025-01-31',
        receivedCount: 5,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(completedStatus.isCompleted, true);
      expect(inProgressStatus.isCompleted, false);
    });

    test('SyncStatus should handle isNoActivities getter correctly', () {
      // Arrange
      final SyncStatus noActivitiesStatus = SyncStatus(
        jobId: 123,
        status: SyncStatusType.noActivities,
        startDate: '2025-01-01',
        endDate: '2025-01-31',
        receivedCount: 0,
        createdAt: DateTime.now(),
      );

      final SyncStatus inProgressStatus = SyncStatus(
        jobId: 123,
        status: SyncStatusType.inProgress,
        startDate: '2025-01-01',
        endDate: '2025-01-31',
        receivedCount: 5,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(noActivitiesStatus.isNoActivities, true);
      expect(inProgressStatus.isNoActivities, false);
    });

    test('SyncStatus should handle isFailed getter correctly', () {
      // Arrange
      final SyncStatus failedStatus = SyncStatus(
        jobId: 123,
        status: SyncStatusType.failed,
        startDate: '2025-01-01',
        endDate: '2025-01-31',
        receivedCount: 3,
        createdAt: DateTime.now(),
      );

      final SyncStatus inProgressStatus = SyncStatus(
        jobId: 123,
        status: SyncStatusType.inProgress,
        startDate: '2025-01-01',
        endDate: '2025-01-31',
        receivedCount: 5,
        createdAt: DateTime.now(),
      );

      // Assert
      expect(failedStatus.isFailed, true);
      expect(inProgressStatus.isFailed, false);
    });
  });
}
