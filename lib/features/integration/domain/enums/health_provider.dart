/// 건강 데이터 제공자 열거형
enum HealthProvider {
  appleHealthKit('Apple HealthKit', 'APPLE-HEALTH-KIT'),
  healthConnect('Health Connect', 'HEALTH-CONNECT'),
  strava('Strava', 'STRAVA');

  const HealthProvider(this.displayName, this.apiProviderName);

  /// API에서 사용하는 providerName (표시용)
  final String displayName;

  /// API에서 사용하는 실제 providerName (서버 전송용)
  final String apiProviderName;

  /// providerName으로부터 HealthProvider 찾기 (API 응답용)
  static HealthProvider? fromProviderName(String providerName) {
    for (final HealthProvider provider in HealthProvider.values) {
      if (provider.apiProviderName == providerName) {
        return provider;
      }
    }
    return null;
  }

  /// UI에서 사용하는 서비스명
  String get serviceName {
    switch (this) {
      case HealthProvider.appleHealthKit:
        return 'Apple Health Kit';
      case HealthProvider.healthConnect:
        return 'Google Health Connect';
      case HealthProvider.strava:
        return 'Strava';
    }
  }
}
