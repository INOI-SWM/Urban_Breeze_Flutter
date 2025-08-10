import 'package:ridingmate/features/auth/domain/entities/auth_login_result.dart';
import 'package:ridingmate/features/auth/domain/repositories/ridingmate_auth_repository.dart';

class LoginWithGoogleIdTokenUseCase {
  const LoginWithGoogleIdTokenUseCase({
    required RidingMateAuthRepository repository,
  }) : _repository = repository;

  final RidingMateAuthRepository _repository;

  Future<AuthLoginResult> execute({required String idToken}) async {
    return _repository.loginWithGoogleIdToken(idToken: idToken);
  }
}
