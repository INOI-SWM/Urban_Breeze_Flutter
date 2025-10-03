/// 건강 데이터 제공자 열거형
enum HealthProvider {
  appleHealthKit('Apple HealthKit'),
  healthConnect('Health Connect'),
  samsungHealth('Samsung Health'),
  garmin('Garmin'),
  suunto('Suunto'),
  strava('Strava');

  const HealthProvider(this.displayName);

  /// API에서 사용하는 providerName
  final String displayName;

  /// providerName으로부터 HealthProvider 찾기
  static HealthProvider? fromProviderName(String providerName) {
    for (final HealthProvider provider in HealthProvider.values) {
      if (provider.displayName == providerName) {
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
      case HealthProvider.samsungHealth:
        return 'Samsung Health';
      case HealthProvider.garmin:
        return 'Garmin Connect';
      case HealthProvider.suunto:
        return 'Suunto';
      case HealthProvider.strava:
        return 'Strava';
    }
  }
}
