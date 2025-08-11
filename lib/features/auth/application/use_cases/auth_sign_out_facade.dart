import 'package:ridingmate/features/auth/application/providers/user_session_notifier.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_out_with_apple_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_out_with_google_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_out_with_kakao_use_case.dart';
import 'package:ridingmate/features/auth/domain/enums/login_provider.dart';
import 'package:ridingmate/features/auth/domain/repositories/token_repository.dart';

class AuthSignOutFacade {
  const AuthSignOutFacade({
    required SignOutWithGoogleUseCase signOutWithGoogleUseCase,
    required SignOutWithAppleUseCase signOutWithAppleUseCase,
    required SignOutWithKakaoUseCase signOutWithKakaoUseCase,
    required UserSessionNotifier userSessionNotifier,
    required TokenRepository tokenRepository,
  }) : _signOutWithGoogleUseCase = signOutWithGoogleUseCase,
       _signOutWithAppleUseCase = signOutWithAppleUseCase,
       _signOutWithKakaoUseCase = signOutWithKakaoUseCase,
       _userSessionNotifier = userSessionNotifier,
       _tokenRepository = tokenRepository;

  final SignOutWithGoogleUseCase _signOutWithGoogleUseCase;
  final SignOutWithAppleUseCase _signOutWithAppleUseCase;
  final SignOutWithKakaoUseCase _signOutWithKakaoUseCase;
  final UserSessionNotifier _userSessionNotifier;
  final TokenRepository _tokenRepository;

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
    await _tokenRepository.clearTokens();
    await _userSessionNotifier.clearUserSession();
  }
}
