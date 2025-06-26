import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class AppleAuthDataSource {
  Future<AuthorizationCredentialAppleID?> signIn();
  Future<void> signOut();
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
  bool get isSignedIn => _currentUser != null;
}
