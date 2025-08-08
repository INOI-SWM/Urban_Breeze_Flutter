import 'package:ridingmate/features/auth/application/use_cases/login_with_apple_idtoken_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/login_with_google_idtoken_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/login_with_kakao_access_token_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_apple_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_google_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_kakao_use_case.dart';
import 'package:ridingmate/features/auth/domain/entities/auth_login_result.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/auth/domain/enums/login_provider.dart';

class AuthSignInFacade {
  const AuthSignInFacade({
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
    required SignInWithKakaoUseCase signInWithKakaoUseCase,
    required LoginWithGoogleIdTokenUseCase loginWithGoogleIdTokenUseCase,
    required LoginWithKakaoAccessTokenUseCase loginWithKakaoAccessTokenUseCase,
    required LoginWithAppleIdTokenUseCase loginWithAppleIdTokenUseCase,
  }) : _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInWithAppleUseCase = signInWithAppleUseCase,
       _signInWithKakaoUseCase = signInWithKakaoUseCase,
       _loginWithGoogleIdTokenUseCase = loginWithGoogleIdTokenUseCase,
       _loginWithKakaoAccessTokenUseCase = loginWithKakaoAccessTokenUseCase,
       _loginWithAppleIdTokenUseCase = loginWithAppleIdTokenUseCase;

  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignInWithKakaoUseCase _signInWithKakaoUseCase;
  final LoginWithGoogleIdTokenUseCase _loginWithGoogleIdTokenUseCase;
  final LoginWithKakaoAccessTokenUseCase _loginWithKakaoAccessTokenUseCase;
  final LoginWithAppleIdTokenUseCase _loginWithAppleIdTokenUseCase;

  Future<User?> signIn(LoginProvider provider) async {
    switch (provider) {
      case LoginProvider.google:
        final User? user = await _signInWithGoogleUseCase.execute();
        if (user != null) {
          final String? idToken = await _signInWithGoogleUseCase.getIdToken();
          if (idToken != null && idToken.isNotEmpty) {
            final AuthLoginResult result = await _loginWithGoogleIdTokenUseCase
                .execute(idToken: idToken);
            // TODO: 토큰 저장
            // TODO: 첫 로그인인지, 두번쨰 로그인 인지 판단하여 다른화면 띄우기
            return result.user;
          }
        }
        return user;
      case LoginProvider.apple:
        final User? user = await _signInWithAppleUseCase.execute();
        if (user != null) {
          final String? idToken = await _signInWithAppleUseCase.getIdToken();
          if (idToken != null && idToken.isNotEmpty) {
            final AuthLoginResult result = await _loginWithAppleIdTokenUseCase
                .execute(idToken: idToken);
            // TODO: 토큰 저장
            // TODO: 첫 로그인 분기 처리
            return result.user;
          }
        }
        return user;
      case LoginProvider.kakao:
        final User? user = await _signInWithKakaoUseCase.execute();
        if (user != null) {
          final String? accessToken =
              await _signInWithKakaoUseCase.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            final AuthLoginResult result =
                await _loginWithKakaoAccessTokenUseCase.execute(
                  accessToken: accessToken,
                );
            // TODO: 토큰 저장
            // TODO: 첫 로그인 처리 분기
            return result.user;
          }
        }
        return user;
    }
  }
}
