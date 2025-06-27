import 'package:ridingmate/features/auth/domain/entities/user.dart';

abstract class GoogleAuthRepository {
  Future<User?> signIn();
  Future<void> signOut();
  Future<void> disconnect();
  Future<User?> getCurrentUser();
  bool get isSignedIn;
}
