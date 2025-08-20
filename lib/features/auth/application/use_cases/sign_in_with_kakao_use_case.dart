import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/repositories/kakao_auth_repository.dart';

class SignInWithKakaoUseCase {
  const SignInWithKakaoUseCase({required KakaoAuthRepository repository})
    : _repository = repository;

  final KakaoAuthRepository _repository;

  Future<User?> execute() async {
    return await _repository.signIn();
  }

  Future<String?> getAccessToken() async {
    try {
      return await _repository.getAccessToken();
    } catch (_) {
      return null;
    }
  }
}
