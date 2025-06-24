import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/login/domain/entities/user.dart';

class UserSessionNotifier extends StateNotifier<User?> {
  UserSessionNotifier() : super(null);

  void signIn(User user) {
    state = user;
  }

  void signOut() {
    state = null;
  }

  bool get isLoggedIn => state != null;
}

final StateNotifierProvider<UserSessionNotifier, User?> userSessionProvider =
    StateNotifierProvider<UserSessionNotifier, User?>(
      (Ref ref) => UserSessionNotifier(),
    );

final Provider<bool> isLoggedInProvider = Provider<bool>(
  (Ref ref) => ref.watch(userSessionProvider) != null,
);
