import 'package:urban_breeze/features/auth/domain/entities/user.dart';

abstract class KakaoAuthRepository {
  Future<User?> signIn();
  Future<void> signOut();
  Future<void> withdraw();
  Future<User?> getCurrentUser();
  bool get isSignedIn;
  Future<String?> getAccessToken();
}
