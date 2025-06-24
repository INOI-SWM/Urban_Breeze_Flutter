import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/auth/di/auth_providers.dart';
import 'package:ridingmate/features/auth/domain/repositories/user_session_repository.dart';
import 'package:ridingmate/features/login/domain/entities/user.dart';

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

final StateNotifierProvider<UserSessionNotifier, User?> userSessionProvider =
    StateNotifierProvider<UserSessionNotifier, User?>(
      (Ref ref) => UserSessionNotifier(
        repository: ref.read(userSessionRepositoryProvider),
      ),
    );

final Provider<bool> isLoggedInProvider = Provider<bool>(
  (Ref<bool> ref) => ref.watch(userSessionProvider) != null,
);
