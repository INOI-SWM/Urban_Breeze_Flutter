import 'package:urban_breeze/features/auth/domain/repositories/apple_auth_repository.dart';

class SignInWithAppleUseCase {
  const SignInWithAppleUseCase({required AppleAuthRepository repository})
    : _repository = repository;

  final AppleAuthRepository _repository;

  Future<String?> execute() async {
    try {
      final bool signInSuccess = await _repository.signIn();
      if (!signInSuccess) {
        return null;
      }
      return await _repository.getIdToken();
    } catch (e) {
      return null;
    }
  }
}
