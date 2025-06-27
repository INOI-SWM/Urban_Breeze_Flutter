import 'package:google_sign_in/google_sign_in.dart';
import 'package:ridingmate/features/auth/data/datasources/google_auth_datasource.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/auth/domain/enums/login_provider.dart';
import 'package:ridingmate/features/auth/domain/repositories/google_auth_repository.dart';

class GoogleAuthRepositoryImpl implements GoogleAuthRepository {
  GoogleAuthRepositoryImpl({required GoogleAuthDataSource googleAuthDataSource})
    : _googleAuthDataSource = googleAuthDataSource;

  final GoogleAuthDataSource _googleAuthDataSource;

  @override
  Future<User?> signIn() async {
    final GoogleSignInAccount? account = await _googleAuthDataSource.signIn();
    if (account == null) return null;

    return User(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
      loginProvider: LoginProvider.google,
    );
  }

  @override
  Future<void> signOut() async {
    await _googleAuthDataSource.signOut();
  }

  @override
  Future<void> disconnect() async {
    await _googleAuthDataSource.disconnect();
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
      loginProvider: LoginProvider.google,
    );
  }

  @override
  bool get isSignedIn => _googleAuthDataSource.isSignedIn;
}
