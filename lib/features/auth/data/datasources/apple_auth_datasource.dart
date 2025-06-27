import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class AppleAuthDataSource {
  Future<AuthorizationCredentialAppleID?> signIn();
  Future<void> signOut();
  Future<void> revokeTokens();
  AuthorizationCredentialAppleID? get currentUser;
  bool get isSignedIn;
}

class AppleAuthDataSourceImpl implements AppleAuthDataSource {
  AppleAuthDataSourceImpl();

  AuthorizationCredentialAppleID? _currentUser;

  @override
  AuthorizationCredentialAppleID? get currentUser => _currentUser;

  @override
  Future<AuthorizationCredentialAppleID?> signIn() async {
    try {
      final bool isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        return null;
      }

      _currentUser = await SignInWithApple.getAppleIDCredential(
        scopes: <AppleIDAuthorizationScopes>[
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      return _currentUser;
    } catch (error) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Apple Sign In은 직접적인 sign out 없음
      _currentUser = null;
    } catch (error) {
      return;
    }
  }

  @override
  Future<void> revokeTokens() async {
    try {
      // TODO: Apple은 탈퇴 로직 서버 측 구현필요 (현재는 로컬 상태만 초기화)
      _currentUser = null;
    } catch (error) {
      _currentUser = null;
      rethrow;
    }
  }

  @override
  bool get isSignedIn => _currentUser != null;
}
