import 'package:urban_breeze/features/auth/data/datasources/apple_auth_datasource.dart';
import 'package:urban_breeze/features/auth/domain/repositories/apple_auth_repository.dart';

class AppleAuthRepositoryImpl implements AppleAuthRepository {
  AppleAuthRepositoryImpl({required AppleAuthDataSource appleAuthDataSource})
    : _appleAuthDataSource = appleAuthDataSource;

  final AppleAuthDataSource _appleAuthDataSource;

  @override
  Future<bool> signIn() async {
    try {
      return await _appleAuthDataSource.signIn();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    await _appleAuthDataSource.signOut();
  }

  @override
  Future<void> withdraw() async {
    await _appleAuthDataSource.revokeTokens();
  }

  @override
  bool get isSignedIn => _appleAuthDataSource.isSignedIn;

  @override
  Future<String?> getIdToken() => _appleAuthDataSource.getIdToken();
}
