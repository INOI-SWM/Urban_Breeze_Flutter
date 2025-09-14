import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleAuthDataSource {
  Future<bool> signIn();
  Future<void> signOut();
  bool get isSignedIn;
  Future<String?> getIdToken();
}

class GoogleAuthDataSourceImpl implements GoogleAuthDataSource {
  GoogleAuthDataSourceImpl()
    : _googleSignIn = GoogleSignIn(scopes: <String>['email', 'profile']);

  final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;

  @override
  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null;
    } catch (error) {
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (error) {
      return;
    }
  }

  @override
  bool get isSignedIn => _currentUser != null;

  @override
  Future<String?> getIdToken() async {
    try {
      final GoogleSignInAccount? user = _currentUser;
      if (user == null) return null;

      final GoogleSignInAuthentication auth = await user.authentication;
      return auth.idToken;
    } catch (error) {
      return null;
    }
  }
}
