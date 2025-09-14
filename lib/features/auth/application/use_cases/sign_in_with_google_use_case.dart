import 'package:urban_breeze/features/auth/domain/repositories/google_auth_repository.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase({required GoogleAuthRepository repository})
    : _repository = repository;

  final GoogleAuthRepository _repository;

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
