import 'package:ridingmate/features/login/domain/entities/user.dart';

abstract class UserSessionRepository {
  Future<void> saveUser(User user);
  Future<User?> loadUser();
  Future<void> clearUser();
}
