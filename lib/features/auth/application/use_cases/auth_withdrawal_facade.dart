import 'package:ridingmate/features/auth/application/providers/user_session_notifier.dart';
import 'package:ridingmate/features/auth/application/use_cases/withdraw_with_apple_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/withdraw_with_google_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/withdraw_with_kakao_use_case.dart';
import 'package:ridingmate/features/auth/domain/enums/login_provider.dart';
import 'package:ridingmate/features/auth/domain/repositories/token_repository.dart';

class AuthWithdrawalFacade {
  const AuthWithdrawalFacade({
    required WithdrawWithGoogleUseCase withdrawWithGoogleUseCase,
    required WithdrawWithAppleUseCase withdrawWithAppleUseCase,
    required WithdrawWithKakaoUseCase withdrawWithKakaoUseCase,
    required UserSessionNotifier userSessionNotifier,
    required TokenRepository tokenRepository,
  }) : _withdrawWithGoogleUseCase = withdrawWithGoogleUseCase,
       _withdrawWithAppleUseCase = withdrawWithAppleUseCase,
       _withdrawWithKakaoUseCase = withdrawWithKakaoUseCase,
       _userSessionNotifier = userSessionNotifier,
       _tokenRepository = tokenRepository;

  final WithdrawWithGoogleUseCase _withdrawWithGoogleUseCase;
  final WithdrawWithAppleUseCase _withdrawWithAppleUseCase;
  final WithdrawWithKakaoUseCase _withdrawWithKakaoUseCase;
  final UserSessionNotifier _userSessionNotifier;
  final TokenRepository _tokenRepository;

  Future<void> execute(LoginProvider loginProvider) async {
    switch (loginProvider) {
      case LoginProvider.google:
        await _withdrawWithGoogleUseCase.execute();
        break;
      case LoginProvider.apple:
        await _withdrawWithAppleUseCase.execute();
        break;
      case LoginProvider.kakao:
        await _withdrawWithKakaoUseCase.execute();
        break;
    }
    await _tokenRepository.clearTokens();
    await _userSessionNotifier.clearUserSession();
  }
}
