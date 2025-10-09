/// Integration Provider 관리 Repository
abstract class ProviderRepository {
  /// Provider 연동 해제
  Future<void> deleteProvider(String providerName);
}

