/// Terra 동기화 상태 엔티티
class SyncStatus {
  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      jobId: json['jobId'] as int,
      status: SyncStatusType.fromString(json['status'] as String),
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      receivedCount: json['receivedCount'] as int,
      lastMessageReceivedAt:
          json['lastMessageReceivedAt'] != null
              ? DateTime.parse(json['lastMessageReceivedAt'] as String)
              : null,
      completedAt:
          json['completedAt'] != null
              ? DateTime.parse(json['completedAt'] as String)
              : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
  const SyncStatus({
    required this.jobId,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.receivedCount,
    required this.createdAt,
    this.lastMessageReceivedAt,
    this.completedAt,
  });

  final int jobId;
  final SyncStatusType status;
  final String startDate;
  final String endDate;
  final int receivedCount;
  final DateTime? lastMessageReceivedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'jobId': jobId,
      'status': status.value,
      'startDate': startDate,
      'endDate': endDate,
      'receivedCount': receivedCount,
      'lastMessageReceivedAt': lastMessageReceivedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isInProgress => status == SyncStatusType.inProgress;
  bool get isCompleted => status == SyncStatusType.completed;
  bool get isNoActivities => status == SyncStatusType.noActivities;
  bool get isFailed => status == SyncStatusType.failed;
}

/// 동기화 상태 타입
enum SyncStatusType {
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  noActivities('NO_ACTIVITIES'),
  failed('FAILED');

  const SyncStatusType(this.value);

  final String value;

  static SyncStatusType fromString(String value) {
    switch (value) {
      case 'IN_PROGRESS':
        return SyncStatusType.inProgress;
      case 'COMPLETED':
        return SyncStatusType.completed;
      case 'NO_ACTIVITIES':
        return SyncStatusType.noActivities;
      case 'FAILED':
        return SyncStatusType.failed;
      default:
        throw ArgumentError('Unknown sync status type: $value');
    }
  }
}
