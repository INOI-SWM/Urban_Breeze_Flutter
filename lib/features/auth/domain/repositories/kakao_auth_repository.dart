import 'package:ridingmate/features/auth/domain/entities/user.dart';

abstract class KakaoAuthRepository {
  Future<User?> signIn();
  Future<void> signOut();
  Future<void> unlink();
  Future<User?> getCurrentUser();
  bool get isSignedIn;
}
