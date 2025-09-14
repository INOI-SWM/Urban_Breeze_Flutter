import 'package:urban_breeze/features/auth/domain/repositories/kakao_auth_repository.dart';

class SignInWithKakaoUseCase {
  const SignInWithKakaoUseCase({required KakaoAuthRepository repository})
    : _repository = repository;

  final KakaoAuthRepository _repository;

  Future<String?> execute() async {
    try {
      final bool signInSuccess = await _repository.signIn();
      if (!signInSuccess) {
        return null;
      }
      return await _repository.getAccessToken();
    } catch (e) {
      return null;
    }
  }
}
