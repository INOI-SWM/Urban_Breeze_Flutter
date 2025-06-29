import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/auth/domain/repositories/user_session_repository.dart';

class UserSessionNotifier extends StateNotifier<User?> {
  UserSessionNotifier({required UserSessionRepository repository})
    : _repository = repository,
      super(null) {
    loadUserSession();
  }

  final UserSessionRepository _repository;

  Future<void> setUserSession(User user) async {
    state = user;
    await _repository.saveUser(user);
  }

  Future<void> clearUserSession() async {
    state = null;
    await _repository.clearUser();
  }

  Future<void> loadUserSession() async {
    final User? user = await _repository.loadUser();
    state = user;
  }

  bool get isLoggedIn => state != null;
}
