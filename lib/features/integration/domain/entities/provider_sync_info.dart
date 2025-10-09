class ProviderSyncInfo {
  const ProviderSyncInfo({
    required this.providerName,
    this.lastSyncAt,
    required this.isActive,
  });

  factory ProviderSyncInfo.fromJson(Map<String, dynamic> json) {
    return ProviderSyncInfo(
      providerName: json['providerName'] as String,
      lastSyncAt:
          json['lastSyncAt'] != null
              ? DateTime.parse(json['lastSyncAt'] as String)
              : null,
      isActive: json['isActive'] as bool,
    );
  }
  final String providerName;
  final DateTime? lastSyncAt;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'providerName': providerName,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'isActive': isActive,
    };
  }
}
