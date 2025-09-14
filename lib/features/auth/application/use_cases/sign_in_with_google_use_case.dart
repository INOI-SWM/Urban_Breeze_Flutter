import 'package:urban_breeze/features/auth/domain/entities/auth_login_result.dart';
import 'package:urban_breeze/features/auth/domain/repositories/google_auth_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/urban_breeze_auth_repository.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase({
    required GoogleAuthRepository googleAuthRepository,
    required UrbanBreezeAuthRepository urbanBreezeAuthRepository,
  }) : _googleAuthRepository = googleAuthRepository,
       _urbanBreezeAuthRepository = urbanBreezeAuthRepository;

  final GoogleAuthRepository _googleAuthRepository;
  final UrbanBreezeAuthRepository _urbanBreezeAuthRepository;

  Future<AuthLoginResult?> execute() async {
    try {
      final bool signInSuccess = await _googleAuthRepository.signIn();
      if (!signInSuccess) {
        return null;
      }

      final String? idToken = await _googleAuthRepository.getIdToken();
      if (idToken == null) {
        return null;
      }

      return await _urbanBreezeAuthRepository.loginWithGoogleIdToken(
        idToken: idToken,
      );
    } catch (e) {
      return null;
    }
  }
}
