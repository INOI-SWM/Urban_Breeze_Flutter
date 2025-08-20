import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/application/providers/user_session_notifier.dart';
import 'package:urban_breeze/features/auth/application/use_cases/login_with_apple_idtoken_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/login_with_google_idtoken_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/login_with_kakao_access_token_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_in_with_apple_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_in_with_google_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_in_with_kakao_use_case.dart';
import 'package:urban_breeze/features/auth/domain/entities/auth_login_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';
import 'package:urban_breeze/features/auth/domain/exceptions/auth_exceptions.dart';
import 'package:urban_breeze/features/auth/domain/repositories/token_repository.dart';

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

  Future<AppResult<User>> _runSignInFlow({
    required Future<User?> Function() doProviderSignIn,
    required Future<String?> Function() getCredential,
    required Future<AuthLoginResult> Function(String) exchange,
  }) async {
    try {
      final User? providerUser = await doProviderSignIn();
      if (providerUser == null) {
        return const AppFailure<User>(AuthCanceledException());
      }

      final String? credential = await getCredential();
      if (credential == null || credential.isEmpty) {
        // 로그인 sdk가 제공하는 자격증명이 없는 경우
        return const AppFailure<User>(AuthCredentialMissingException());
      }

      final AuthLoginResult result = await exchange(credential);
      await _tokenRepository.saveTokens(result.tokens);
      await _userSessionNotifier.setUserSession(result.user);
      return AppSuccess<User>(result.user);
    } catch (e) {
      return const AppFailure<User>(AuthExchangeFailedException());
    }
  }

  Future<AppResult<User>> signIn(LoginProvider provider) async {
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
