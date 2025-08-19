import 'package:urban_breeze/features/auth/domain/entities/auth_login_result.dart';
import 'package:urban_breeze/features/auth/domain/repositories/urban_breeze_auth_repository.dart';

class LoginWithKakaoAccessTokenUseCase {
  const LoginWithKakaoAccessTokenUseCase({
    required UrbanBreezeAuthRepository repository,
  }) : _repository = repository;

  final UrbanBreezeAuthRepository _repository;

  Future<AuthLoginResult> execute({required String accessToken}) async {
    return _repository.loginWithKakaoAccessToken(accessToken: accessToken);
  }
}
