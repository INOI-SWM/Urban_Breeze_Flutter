import 'package:urban_breeze/features/auth/domain/repositories/google_auth_repository.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase({required GoogleAuthRepository repository})
    : _repository = repository;

  final GoogleAuthRepository _repository;

  Future<bool> execute() async {
    try {
      await _repository.signIn();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getIdToken() async => _repository.getIdToken();
}
