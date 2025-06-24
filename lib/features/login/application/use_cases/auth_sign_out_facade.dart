import 'package:ridingmate/features/login/application/use_cases/sign_out_with_apple_use_case.dart';
import 'package:ridingmate/features/login/application/use_cases/sign_out_with_google_use_case.dart';
import 'package:ridingmate/features/login/application/use_cases/sign_out_with_kakao_use_case.dart';
import 'package:ridingmate/features/login/domain/entities/user.dart';

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

  Future<void> execute(User user) async {
    switch (user.loginProvider) {
      case 'google':
        await _signOutWithGoogleUseCase.execute();
        break;
      case 'apple':
        await _signOutWithAppleUseCase.execute();
        break;
      case 'kakao':
        await _signOutWithKakaoUseCase.execute();
        break;
      default:
        throw UnsupportedError(
          'Unsupported login provider: ${user.loginProvider}',
        );
    }
  }
}
