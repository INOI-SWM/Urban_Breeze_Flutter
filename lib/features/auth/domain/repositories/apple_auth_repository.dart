import 'package:ridingmate/features/auth/domain/entities/user.dart';

abstract class AppleAuthRepository {
  Future<User?> signIn();
  Future<void> signOut();
  Future<void> revokeTokens();
  Future<User?> getCurrentUser();
  bool get isSignedIn;
}
