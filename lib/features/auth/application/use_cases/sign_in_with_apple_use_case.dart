import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/auth/domain/repositories/apple_auth_repository.dart';

class SignInWithAppleUseCase {
  const SignInWithAppleUseCase({required AppleAuthRepository repository})
    : _repository = repository;

  final AppleAuthRepository _repository;

  Future<User?> execute() async {
    return await _repository.signIn();
  }
}
