import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_apple_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_google_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_kakao_use_case.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/auth/domain/enums/login_provider.dart';

class AuthSignInFacade {
  const AuthSignInFacade({
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
    required SignInWithKakaoUseCase signInWithKakaoUseCase,
  }) : _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInWithAppleUseCase = signInWithAppleUseCase,
       _signInWithKakaoUseCase = signInWithKakaoUseCase;

  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignInWithKakaoUseCase _signInWithKakaoUseCase;

  Future<User?> signIn(LoginProvider provider) async {
    switch (provider) {
      case LoginProvider.google:
        return await _signInWithGoogleUseCase.execute();
      case LoginProvider.apple:
        return await _signInWithAppleUseCase.execute();
      case LoginProvider.kakao:
        return await _signInWithKakaoUseCase.execute();
    }
  }
}
