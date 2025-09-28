import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/entities/user_agreement.dart';

abstract class UserSessionRepository {
  Future<void> saveUser(User user);
  Future<User?> loadUser();
  Future<void> clearUser();

  Future<void> saveUserAgreement(UserAgreement agreement);
  Future<UserAgreement?> loadUserAgreement();
  Future<void> clearUserAgreement();
}
