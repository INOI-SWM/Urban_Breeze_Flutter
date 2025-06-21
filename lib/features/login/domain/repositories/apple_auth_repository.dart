import 'package:ridingmate/features/login/domain/entities/user.dart';

abstract class AppleAuthRepository {
  Future<User?> signIn();
  Future<void> signOut();
  Future<User?> getCurrentUser();
  bool get isSignedIn;
}
