import 'package:urban_breeze/features/auth/domain/entities/auth_login_result.dart';
import 'package:urban_breeze/features/auth/domain/repositories/apple_auth_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/urban_breeze_auth_repository.dart';

class SignInWithAppleUseCase {
  const SignInWithAppleUseCase({
    required AppleAuthRepository appleAuthRepository,
    required UrbanBreezeAuthRepository urbanBreezeAuthRepository,
  }) : _appleAuthRepository = appleAuthRepository,
       _urbanBreezeAuthRepository = urbanBreezeAuthRepository;

  final AppleAuthRepository _appleAuthRepository;
  final UrbanBreezeAuthRepository _urbanBreezeAuthRepository;

  Future<AuthLoginResult?> execute() async {
    try {
      final bool signInSuccess = await _appleAuthRepository.signIn();
      if (!signInSuccess) {
        return null;
      }

      final String? idToken = await _appleAuthRepository.getIdToken();
      if (idToken == null) {
        return null;
      }

      return await _urbanBreezeAuthRepository.loginWithAppleIdToken(
        idToken: idToken,
      );
    } catch (e) {
      return null;
    }
  }
}
