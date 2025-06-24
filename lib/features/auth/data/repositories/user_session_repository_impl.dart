import 'dart:convert';

import 'package:ridingmate/features/auth/domain/repositories/user_session_repository.dart';
import 'package:ridingmate/features/login/domain/entities/user.dart';
import 'package:ridingmate/features/login/domain/enums/login_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionRepositoryImpl implements UserSessionRepository {
  static const String _userKey = 'user_session';

  @override
  Future<void> saveUser(User user) async {
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

  @override
  Future<User?> loadUser() async {
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

  @override
  Future<void> clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
