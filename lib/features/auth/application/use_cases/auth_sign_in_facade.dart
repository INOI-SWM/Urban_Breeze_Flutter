import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/application/providers/user_session_notifier.dart';
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
    required TokenRepository tokenRepository,
    required UserSessionNotifier userSessionNotifier,
    required UserAgreementNotifier userAgreementNotifier,
  }) : _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInWithAppleUseCase = signInWithAppleUseCase,
       _signInWithKakaoUseCase = signInWithKakaoUseCase,
       _tokenRepository = tokenRepository,
       _userSessionNotifier = userSessionNotifier,
       _userAgreementNotifier = userAgreementNotifier;

  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SignInWithKakaoUseCase _signInWithKakaoUseCase;
  final TokenRepository _tokenRepository;
  final UserSessionNotifier _userSessionNotifier;
  final UserAgreementNotifier _userAgreementNotifier;

  Future<AppResult<User>> signIn(LoginProvider provider) async {
    try {
      final AuthLoginResult? result = switch (provider) {
        LoginProvider.google => await _signInWithGoogleUseCase.execute(),
        LoginProvider.apple => await _signInWithAppleUseCase.execute(),
        LoginProvider.kakao => await _signInWithKakaoUseCase.execute(),
      };

      if (result == null) {
        return const AppFailure<User>(AuthCanceledException());
      }

      await _tokenRepository.saveTokens(result.tokens);
      await _userSessionNotifier.setUserSession(result.user);
      await _userAgreementNotifier.setUserAgreement(result.agreement);
      return AppSuccess<User>(result.user);
    } catch (e) {
      return const AppFailure<User>(AuthExchangeFailedException());
    }
  }
}
