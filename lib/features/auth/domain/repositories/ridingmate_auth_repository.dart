abstract class RidingMateAuthRepository {
  Future<Map<String, dynamic>> loginWithGoogleIdToken({
    required String idToken,
  });
}
