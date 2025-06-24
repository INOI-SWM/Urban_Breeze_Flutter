import 'package:ridingmate/features/login/application/use_cases/sign_out_with_apple_use_case.dart';
import 'package:ridingmate/features/login/application/use_cases/sign_out_with_google_use_case.dart';
import 'package:ridingmate/features/login/application/use_cases/sign_out_with_kakao_use_case.dart';
import 'package:ridingmate/features/login/domain/enums/login_provider.dart';

class AuthSignOutFacade {
  const AuthSignOutFacade({
    required SignOutWithGoogleUseCase signOutWithGoogleUseCase,
    required SignOutWithAppleUseCase signOutWithAppleUseCase,
    required SignOutWithKakaoUseCase signOutWithKakaoUseCase,
  }) : _signOutWithGoogleUseCase = signOutWithGoogleUseCase,
       _signOutWithAppleUseCase = signOutWithAppleUseCase,
       _signOutWithKakaoUseCase = signOutWithKakaoUseCase;

  final SignOutWithGoogleUseCase _signOutWithGoogleUseCase;
  final SignOutWithAppleUseCase _signOutWithAppleUseCase;
  final SignOutWithKakaoUseCase _signOutWithKakaoUseCase;

  Future<void> execute(LoginProvider loginProvider) async {
    switch (loginProvider) {
      case LoginProvider.google:
        await _signOutWithGoogleUseCase.execute();
        break;
      case LoginProvider.apple:
        await _signOutWithAppleUseCase.execute();
        break;
      case LoginProvider.kakao:
        await _signOutWithKakaoUseCase.execute();
        break;
    }
  }
}
