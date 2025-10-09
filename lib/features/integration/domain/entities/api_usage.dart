import 'package:urban_breeze/features/integration/domain/entities/provider_sync_info.dart';

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
