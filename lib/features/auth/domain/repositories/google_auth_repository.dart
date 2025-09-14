abstract class GoogleAuthRepository {
  Future<bool> signIn();
  Future<void> signOut();
  Future<void> withdraw();
  bool get isSignedIn;
  Future<String?> getIdToken();
}
