import 'package:ridingmate/features/auth/application/use_cases/login_with_google_idtoken_use_case.dart';
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
  }) : _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInWithAppleUseCase = signInWithAppleUseCase,
       _signInWithKakaoUseCase = signInWithKakaoUseCase,
       _loginWithGoogleIdTokenUseCase = loginWithGoogleIdTokenUseCase;

  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignInWithKakaoUseCase _signInWithKakaoUseCase;
  final LoginWithGoogleIdTokenUseCase _loginWithGoogleIdTokenUseCase;

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
        return await _signInWithAppleUseCase.execute();
      case LoginProvider.kakao:
        return await _signInWithKakaoUseCase.execute();
    }
  }
}
