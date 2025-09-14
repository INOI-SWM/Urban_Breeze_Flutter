import 'package:urban_breeze/features/auth/domain/entities/auth_login_result.dart';
import 'package:urban_breeze/features/auth/domain/repositories/kakao_auth_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/urban_breeze_auth_repository.dart';

class SignInWithKakaoUseCase {
  const SignInWithKakaoUseCase({
    required KakaoAuthRepository kakaoAuthRepository,
    required UrbanBreezeAuthRepository urbanBreezeAuthRepository,
  }) : _kakaoAuthRepository = kakaoAuthRepository,
       _urbanBreezeAuthRepository = urbanBreezeAuthRepository;

  final KakaoAuthRepository _kakaoAuthRepository;
  final UrbanBreezeAuthRepository _urbanBreezeAuthRepository;

  Future<AuthLoginResult?> execute() async {
    try {
      final bool signInSuccess = await _kakaoAuthRepository.signIn();
      if (!signInSuccess) {
        return null;
      }

      final String? accessToken = await _kakaoAuthRepository.getAccessToken();
      if (accessToken == null) {
        return null;
      }

      return await _urbanBreezeAuthRepository.loginWithKakaoAccessToken(
        accessToken: accessToken,
      );
    } catch (e) {
      return null;
    }
  }
}
