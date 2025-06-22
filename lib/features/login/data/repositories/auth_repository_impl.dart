import 'package:google_sign_in/google_sign_in.dart';
import 'package:ridingmate/features/login/data/datasources/google_auth_datasource.dart';
import 'package:ridingmate/features/login/domain/entities/user.dart';
import 'package:ridingmate/features/login/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required GoogleAuthDataSource googleAuthDataSource})
    : _googleAuthDataSource = googleAuthDataSource;

  final GoogleAuthDataSource _googleAuthDataSource;

  @override
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? account = await _googleAuthDataSource.signIn();
    if (account == null) return null;

    return User(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
    );
  }

  @override
  Future<void> signOut() async {
    await _googleAuthDataSource.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final GoogleSignInAccount? account = _googleAuthDataSource.currentUser;
    if (account == null) return null;

    return User(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
    );
  }

  @override
  bool get isSignedIn => _googleAuthDataSource.isSignedIn;
}
