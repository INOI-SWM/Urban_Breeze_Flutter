import 'package:ridingmate/features/login/domain/repositories/apple_auth_repository.dart';

class SignOutWithAppleUseCase {
  const SignOutWithAppleUseCase({required AppleAuthRepository repository})
    : _repository = repository;

  final AppleAuthRepository _repository;

  Future<void> execute() async {
    await _repository.signOut();
  }
}
