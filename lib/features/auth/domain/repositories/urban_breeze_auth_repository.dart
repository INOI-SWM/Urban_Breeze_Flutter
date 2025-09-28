import 'package:urban_breeze/features/auth/domain/entities/auth_login_result.dart';

abstract class UrbanBreezeAuthRepository {
  Future<AuthLoginResult> loginWithGoogleIdToken({required String idToken});
  Future<AuthLoginResult> loginWithKakaoAccessToken({
    required String accessToken,
  });
  Future<AuthLoginResult> loginWithAppleIdToken({required String idToken});
  Future<void> deleteUser();
}
