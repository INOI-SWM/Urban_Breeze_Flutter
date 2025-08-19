import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/application/providers/user_session_notifier.dart';
import 'package:urban_breeze/features/auth/application/use_cases/withdraw_with_apple_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/withdraw_with_google_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/withdraw_with_kakao_use_case.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';
import 'package:urban_breeze/features/auth/domain/repositories/token_repository.dart';

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

  Future<AppResult<void>> execute(LoginProvider loginProvider) async {
    try {
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
      return const AppSuccess<void>(null);
    } catch (e) {
      return const AppFailure<void>(ServerException('탈퇴 처리에 실패했습니다'));
    }
  }
}
