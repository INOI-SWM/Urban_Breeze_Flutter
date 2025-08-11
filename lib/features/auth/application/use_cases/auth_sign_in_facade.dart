import 'package:ridingmate/features/auth/application/providers/user_session_notifier.dart';
import 'package:ridingmate/features/auth/application/use_cases/login_with_apple_idtoken_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/login_with_google_idtoken_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/login_with_kakao_access_token_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_apple_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_google_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_kakao_use_case.dart';
import 'package:ridingmate/features/auth/domain/entities/auth_login_result.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/auth/domain/enums/login_provider.dart';
import 'package:ridingmate/features/auth/domain/repositories/token_repository.dart';

class AuthSignInFacade {
  const AuthSignInFacade({
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
    required SignInWithKakaoUseCase signInWithKakaoUseCase,
    required LoginWithGoogleIdTokenUseCase loginWithGoogleIdTokenUseCase,
    required LoginWithKakaoAccessTokenUseCase loginWithKakaoAccessTokenUseCase,
    required LoginWithAppleIdTokenUseCase loginWithAppleIdTokenUseCase,
    required TokenRepository tokenRepository,
    required UserSessionNotifier userSessionNotifier,
  }) : _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInWithAppleUseCase = signInWithAppleUseCase,
       _signInWithKakaoUseCase = signInWithKakaoUseCase,
       _loginWithGoogleIdTokenUseCase = loginWithGoogleIdTokenUseCase,
       _loginWithKakaoAccessTokenUseCase = loginWithKakaoAccessTokenUseCase,
       _loginWithAppleIdTokenUseCase = loginWithAppleIdTokenUseCase,
       _tokenRepository = tokenRepository,
       _userSessionNotifier = userSessionNotifier;

  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignInWithKakaoUseCase _signInWithKakaoUseCase;
  final LoginWithGoogleIdTokenUseCase _loginWithGoogleIdTokenUseCase;
  final LoginWithKakaoAccessTokenUseCase _loginWithKakaoAccessTokenUseCase;
  final LoginWithAppleIdTokenUseCase _loginWithAppleIdTokenUseCase;
  final TokenRepository _tokenRepository;
  final UserSessionNotifier _userSessionNotifier;

  Future<User?> _runSignInFlow({
    required Future<User?> Function() doProviderSignIn,
    required Future<String?> Function() getCredential,
    required Future<AuthLoginResult> Function(String) exchange,
  }) async {
    final User? providerUser = await doProviderSignIn();
    if (providerUser == null) return null;

    final String? credential = await getCredential();
    if (credential == null || credential.isEmpty) return providerUser;

    final AuthLoginResult result = await exchange(credential);
    await _tokenRepository.saveTokens(result.tokens);
    await _userSessionNotifier.setUserSession(result.user);
    return result.user;
  }

  Future<User?> signIn(LoginProvider provider) async {
    switch (provider) {
      case LoginProvider.google:
        return _runSignInFlow(
          doProviderSignIn: _signInWithGoogleUseCase.execute,
          getCredential: _signInWithGoogleUseCase.getIdToken,
          exchange:
              (String idToken) =>
                  _loginWithGoogleIdTokenUseCase.execute(idToken: idToken),
        );
      case LoginProvider.apple:
        return _runSignInFlow(
          doProviderSignIn: _signInWithAppleUseCase.execute,
          getCredential: _signInWithAppleUseCase.getIdToken,
          exchange:
              (String idToken) =>
                  _loginWithAppleIdTokenUseCase.execute(idToken: idToken),
        );
      case LoginProvider.kakao:
        return _runSignInFlow(
          doProviderSignIn: _signInWithKakaoUseCase.execute,
          getCredential: _signInWithKakaoUseCase.getAccessToken,
          exchange:
              (String accessToken) => _loginWithKakaoAccessTokenUseCase.execute(
                accessToken: accessToken,
              ),
        );
    }
  }
}
