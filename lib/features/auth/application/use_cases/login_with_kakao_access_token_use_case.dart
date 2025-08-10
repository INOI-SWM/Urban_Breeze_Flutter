import 'package:ridingmate/features/auth/domain/entities/auth_login_result.dart';
import 'package:ridingmate/features/auth/domain/repositories/ridingmate_auth_repository.dart';

class LoginWithKakaoAccessTokenUseCase {
  const LoginWithKakaoAccessTokenUseCase({
    required RidingMateAuthRepository repository,
  }) : _repository = repository;

  final RidingMateAuthRepository _repository;

  Future<AuthLoginResult> execute({required String accessToken}) async {
    return _repository.loginWithKakaoAccessToken(accessToken: accessToken);
  }
}
