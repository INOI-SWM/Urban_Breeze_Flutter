import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/application/providers/user_session_notifier.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';
import 'package:urban_breeze/features/auth/domain/repositories/apple_auth_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/google_auth_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/kakao_auth_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/token_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/urban_breeze_auth_repository.dart';

class AuthWithdrawalFacade {
  const AuthWithdrawalFacade({
    required GoogleAuthRepository googleAuthRepository,
    required AppleAuthRepository appleAuthRepository,
    required KakaoAuthRepository kakaoAuthRepository,
    required UserSessionNotifier userSessionNotifier,
    required TokenRepository tokenRepository,
    required UrbanBreezeAuthRepository urbanBreezeAuthRepository,
    required UserAgreementNotifier userAgreementNotifier,
  }) : _googleAuthRepository = googleAuthRepository,
       _appleAuthRepository = appleAuthRepository,
       _kakaoAuthRepository = kakaoAuthRepository,
       _userSessionNotifier = userSessionNotifier,
       _tokenRepository = tokenRepository,
       _urbanBreezeAuthRepository = urbanBreezeAuthRepository,
       _userAgreementNotifier = userAgreementNotifier;

  final GoogleAuthRepository _googleAuthRepository;
  final AppleAuthRepository _appleAuthRepository;
  final KakaoAuthRepository _kakaoAuthRepository;
  final UserSessionNotifier _userSessionNotifier;
  final TokenRepository _tokenRepository;
  final UrbanBreezeAuthRepository _urbanBreezeAuthRepository;
  final UserAgreementNotifier _userAgreementNotifier;

  Future<AppResult<void>> execute(LoginProvider loginProvider) async {
    try {
      await _urbanBreezeAuthRepository.deleteUser();

      await _performProviderAction(
        loginProvider,
        (dynamic repo) => repo.withdraw(),
      );

      await _clearSession();

      return const AppSuccess<void>(null);
    } catch (e) {
      return const AppFailure<void>(ServerException('탈퇴 처리에 실패했습니다'));
    }
  }

  Future<void> _performProviderAction(
    LoginProvider loginProvider,
    Future<void> Function(dynamic repository) action,
  ) async {
    switch (loginProvider) {
      case LoginProvider.google:
        await action(_googleAuthRepository);
        break;
      case LoginProvider.apple:
        await action(_appleAuthRepository);
        break;
      case LoginProvider.kakao:
        await action(_kakaoAuthRepository);
        break;
    }
  }

  Future<void> _clearSession() async {
    await _tokenRepository.clearTokens();
    await _userSessionNotifier.clearUserSession();
    await _userAgreementNotifier.clearUserAgreement();
  }
}
