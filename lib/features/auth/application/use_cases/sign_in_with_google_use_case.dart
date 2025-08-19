import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/repositories/google_auth_repository.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase({required GoogleAuthRepository repository})
    : _repository = repository;

  final GoogleAuthRepository _repository;

  Future<User?> execute() async {
    return await _repository.signIn();
  }

  Future<String?> getIdToken() async => _repository.getIdToken();
}
