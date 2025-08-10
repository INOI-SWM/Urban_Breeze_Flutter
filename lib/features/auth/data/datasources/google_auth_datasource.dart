import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleAuthDataSource {
  Future<GoogleSignInAccount?> signIn();
  Future<void> signOut();
  Future<GoogleSignInAccount?> signInSilently();
  GoogleSignInAccount? get currentUser;
  bool get isSignedIn;
  Future<void> disconnect();
  Future<String?> getIdToken();
}

class GoogleAuthDataSourceImpl implements GoogleAuthDataSource {
  GoogleAuthDataSourceImpl()
    : _googleSignIn = GoogleSignIn(scopes: <String>['email', 'profile']);

  final GoogleSignIn _googleSignIn;
  GoogleSignInAccount? _currentUser;

  @override
  GoogleSignInAccount? get currentUser => _currentUser;

  @override
  Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser;
    } catch (error) {
      return null;
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
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      return _currentUser;
    } catch (error) {
      return null;
    }
  }

  @override
  bool get isSignedIn => _currentUser != null;

  @override
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      _currentUser = null;
    } catch (error) {
      return;
    }
  }

  @override
  Future<String?> getIdToken() async {
    try {
      GoogleSignInAccount? user = _currentUser;
      user ??= await _googleSignIn.signInSilently();
      if (user == null) return null;

      final GoogleSignInAuthentication auth = await user.authentication;
      return auth.idToken;
    } catch (error) {
      return null;
    }
  }
}
