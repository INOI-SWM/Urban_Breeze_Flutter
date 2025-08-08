import 'package:ridingmate/features/auth/domain/entities/auth_login_result.dart';

abstract class RidingMateAuthRepository {
  Future<AuthLoginResult> loginWithGoogleIdToken({required String idToken});
  Future<AuthLoginResult> loginWithKakaoAccessToken({
    required String accessToken,
  });
  Future<AuthLoginResult> loginWithAppleIdToken({required String idToken});
}
