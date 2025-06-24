import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/login/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionNotifier extends StateNotifier<User?> {
  UserSessionNotifier() : super(null) {
    _loadUserSession();
  }

  static const String _userSessionKey = 'user_session';

  Future<void> _loadUserSession() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString(_userSessionKey);

      if (userJson != null) {
        final Map<String, dynamic> userMap =
            jsonDecode(userJson) as Map<String, dynamic>;
        final User user = User(
          id: userMap['id'],
          email: userMap['email'],
          displayName: userMap['displayName'],
          photoUrl: userMap['photoUrl'],
        );
        state = user;
      }
    } catch (e) {
      state = null;
    }
  }

  Future<void> setUserSession(User user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final Map<String, String?> userMap = <String, String?>{
        'id': user.id,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoUrl,
      };
      await prefs.setString(_userSessionKey, jsonEncode(userMap));
      state = user;
    } catch (e) {
      state = user;
    }
  }

  Future<void> clearUserSession() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userSessionKey);
    } catch (e) {
      debugPrint('Failed to clear user session: $e');
    }
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
