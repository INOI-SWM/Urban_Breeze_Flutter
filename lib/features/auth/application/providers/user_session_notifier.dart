import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/auth/domain/repositories/user_session_repository.dart';

class UserSessionNotifier extends StateNotifier<User?> {
  UserSessionNotifier({
    required UserSessionRepository repository,
    void Function()? onInitialized,
  }) : _repository = repository,
       _onInitialized = onInitialized,
       super(null) {
    loadUserSession();
  }

  final UserSessionRepository _repository;
  final void Function()? _onInitialized;

  Future<void> setUserSession(User user) async {
    state = user;
    await _repository.saveUser(user);
  }

  Future<void> clearUserSession() async {
    state = null;
    await _repository.clearUser();
  }

  Future<void> loadUserSession() async {
    // 최소 500ms 지연으로 스플래시 화면이 너무 빨리 사라지지 않도록
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final User? user = await _repository.loadUser();
    state = user;
    // 초기화 완료 알림
    _onInitialized?.call();
  }

  bool get isLoggedIn => state != null;
}

class AuthInitializationNotifier extends StateNotifier<bool> {
  AuthInitializationNotifier() : super(false);

  void markInitialized() {
    state = true;
  }
}
