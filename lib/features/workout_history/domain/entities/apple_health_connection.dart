class AppleHealthConnection {
  const AppleHealthConnection({
    required this.isConnected,
    required this.connectedAt,
    this.lastSyncAt,
    required this.message,
  });

  factory AppleHealthConnection.fromJson(Map<String, dynamic> json) {
    return AppleHealthConnection(
      isConnected: json['isConnected'] as bool,
      connectedAt: DateTime.parse(json['connectedAt'] as String),
      lastSyncAt:
          json['lastSyncAt'] != null
              ? DateTime.parse(json['lastSyncAt'] as String)
              : null,
      message: json['message'] as String,
    );
  }
  final bool isConnected;
  final DateTime connectedAt;
  final DateTime? lastSyncAt;
  final String message;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isConnected': isConnected,
      'connectedAt': connectedAt.toIso8601String(),
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'message': message,
    };
  }
}
