import 'package:urban_breeze/features/auth/domain/entities/auth_login_result.dart';
import 'package:urban_breeze/features/auth/domain/repositories/urban_breeze_auth_repository.dart';

class LoginWithGoogleIdTokenUseCase {
  const LoginWithGoogleIdTokenUseCase({
    required UrbanBreezeAuthRepository repository,
  }) : _repository = repository;

  final UrbanBreezeAuthRepository _repository;

  Future<AuthLoginResult> execute({required String idToken}) async {
    return _repository.loginWithGoogleIdToken(idToken: idToken);
  }
}
