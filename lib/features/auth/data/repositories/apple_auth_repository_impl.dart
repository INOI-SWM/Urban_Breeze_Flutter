import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:urban_breeze/features/auth/data/datasources/apple_auth_datasource.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';
import 'package:urban_breeze/features/auth/domain/repositories/apple_auth_repository.dart';

class AppleAuthRepositoryImpl implements AppleAuthRepository {
  AppleAuthRepositoryImpl({required AppleAuthDataSource appleAuthDataSource})
    : _appleAuthDataSource = appleAuthDataSource;

  final AppleAuthDataSource _appleAuthDataSource;

  @override
  Future<User?> signIn() async {
    final AuthorizationCredentialAppleID? account =
        await _appleAuthDataSource.signIn();
    if (account == null) return null;

    String? displayName;
    if (account.givenName != null || account.familyName != null) {
      displayName =
          '${account.givenName ?? ''} ${account.familyName ?? ''}'.trim();
      if (displayName.isEmpty) displayName = null;
    }

    return User(
      uuid: account.userIdentifier!,
      nickname: displayName ?? 'Apple User',
      email: account.email ?? '',
      profileImagePath: null, // Apple은 프로필 사진을 제공하지 않음
      displayName: displayName,
      loginProvider: LoginProvider.apple,
    );
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
  Future<User?> getCurrentUser() async {
    final AuthorizationCredentialAppleID? account =
        _appleAuthDataSource.currentUser;
    if (account == null) return null;

    String? displayName;
    if (account.givenName != null || account.familyName != null) {
      displayName =
          '${account.givenName ?? ''} ${account.familyName ?? ''}'.trim();
      if (displayName.isEmpty) displayName = null;
    }

    return User(
      uuid: account.userIdentifier!,
      nickname: displayName ?? 'Apple User',
      email: account.email ?? '',
      profileImagePath: null,
      displayName: displayName,
      loginProvider: LoginProvider.apple,
    );
  }

  @override
  bool get isSignedIn => _appleAuthDataSource.isSignedIn;

  @override
  Future<String?> getIdToken() => _appleAuthDataSource.getIdToken();
}
