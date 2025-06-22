import 'package:ridingmate/features/login/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User?> signInWithGoogle();
  Future<void> signOut();
  Future<User?> getCurrentUser();
  bool get isSignedIn;
}
