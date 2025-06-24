import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/login/domain/entities/user.dart';
import 'package:ridingmate/features/login/domain/enums/login_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionNotifier extends StateNotifier<User?> {
  UserSessionNotifier() : super(null) {
    loadUserSession();
  }

  static const String _userKey = 'user_session';

  Future<void> setUserSession(User user) async {
    state = user;
    await _saveUserToStorage(user);
  }

  Future<void> clearUserSession() async {
    state = null;
    await _removeUserFromStorage();
  }

  Future<void> loadUserSession() async {
    final User? user = await _loadUserFromStorage();
    state = user;
  }

  Future<void> _saveUserToStorage(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, String?> userJson = <String, String?>{
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'loginProvider': user.loginProvider.name,
    };
    await prefs.setString(_userKey, jsonEncode(userJson));
  }

  Future<User?> _loadUserFromStorage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userJsonString = prefs.getString(_userKey);

      if (userJsonString == null) return null;

      final Map<String, dynamic> userJson =
          jsonDecode(userJsonString) as Map<String, dynamic>;

      return User(
        id: userJson['id'] as String,
        email: userJson['email'] as String,
        displayName: userJson['displayName'] as String?,
        photoUrl: userJson['photoUrl'] as String?,
        loginProvider: LoginProviderExtension.fromJson(
          userJson['loginProvider'] as String,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _removeUserFromStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
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
