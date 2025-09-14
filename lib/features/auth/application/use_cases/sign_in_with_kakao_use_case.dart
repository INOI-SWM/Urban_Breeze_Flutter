import 'package:urban_breeze/features/auth/domain/repositories/kakao_auth_repository.dart';

class SignInWithKakaoUseCase {
  const SignInWithKakaoUseCase({required KakaoAuthRepository repository})
    : _repository = repository;

  final KakaoAuthRepository _repository;

  Future<bool> execute() async {
    try {
      await _repository.signIn();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _repository.getAccessToken();
    } catch (_) {
      return null;
    }
  }
}
