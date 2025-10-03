class ApiUsage {
  const ApiUsage({
    required this.currentUsage,
    required this.monthlyLimit,
    required this.remainingUsage,
    required this.isExceeded,
    required this.providerSyncInfos,
  });

  factory ApiUsage.fromJson(Map<String, dynamic> json) {
    return ApiUsage(
      currentUsage: json['currentUsage'] as int,
      monthlyLimit: json['monthlyLimit'] as int,
      remainingUsage: json['remainingUsage'] as int,
      isExceeded: json['isExceeded'] as bool,
      providerSyncInfos:
          (json['providerSyncInfos'] as List<dynamic>)
              .map(
                (dynamic item) =>
                    ProviderSyncInfo.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }
  final int currentUsage;
  final int monthlyLimit;
  final int remainingUsage;
  final bool isExceeded;
  final List<ProviderSyncInfo> providerSyncInfos;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'currentUsage': currentUsage,
      'monthlyLimit': monthlyLimit,
      'remainingUsage': remainingUsage,
      'isExceeded': isExceeded,
      'providerSyncInfos':
          providerSyncInfos
              .map((ProviderSyncInfo item) => item.toJson())
              .toList(),
    };
  }
}

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
