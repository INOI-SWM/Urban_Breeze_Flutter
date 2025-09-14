import 'package:google_sign_in/google_sign_in.dart';
import 'package:urban_breeze/features/auth/data/datasources/google_auth_datasource.dart';
import 'package:urban_breeze/features/auth/domain/repositories/google_auth_repository.dart';

class GoogleAuthRepositoryImpl implements GoogleAuthRepository {
  GoogleAuthRepositoryImpl({required GoogleAuthDataSource googleAuthDataSource})
    : _googleAuthDataSource = googleAuthDataSource;

  final GoogleAuthDataSource _googleAuthDataSource;

  @override
  Future<bool> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleAuthDataSource.signIn();
      return account != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    await _googleAuthDataSource.signOut();
  }

  @override
  Future<void> withdraw() async {
    await _googleAuthDataSource.disconnect();
  }

  @override
  bool get isSignedIn => _googleAuthDataSource.isSignedIn;

  @override
  Future<String?> getIdToken() => _googleAuthDataSource.getIdToken();
}
