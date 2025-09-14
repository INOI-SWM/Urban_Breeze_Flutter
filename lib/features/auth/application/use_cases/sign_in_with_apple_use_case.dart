import 'package:urban_breeze/features/auth/domain/repositories/apple_auth_repository.dart';

class SignInWithAppleUseCase {
  const SignInWithAppleUseCase({required AppleAuthRepository repository})
    : _repository = repository;

  final AppleAuthRepository _repository;

  Future<bool> execute() async {
    try {
      await _repository.signIn();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getIdToken() async {
    try {
      return await _repository.getIdToken();
    } catch (_) {
      return null;
    }
  }
}
