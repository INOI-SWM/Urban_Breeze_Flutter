import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/entities/user_agreement.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';
import 'package:urban_breeze/features/auth/domain/repositories/user_session_repository.dart';

class UserSessionRepositoryImpl implements UserSessionRepository {
  static const String _userKey = 'user_session';
  static const String _userAgreementKey = 'user_agreement';

  @override
  Future<void> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> userJson = <String, dynamic>{
      'uuid': user.uuid,
      'nickname': user.nickname,
      'email': user.email,
      'profileImageUrl': user.profileImageUrl,
      'introduce': user.introduce,
      'birthYear': user.birthYear,
      'gender': user.gender,
      'displayName': user.displayName,
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
        uuid: userJson['uuid'] as String,
        nickname: userJson['nickname'] as String,
        email: userJson['email'] as String,
        profileImageUrl: userJson['profileImageUrl'] as String?,
        introduce: userJson['introduce'] as String?,
        birthYear: userJson['birthYear'] as int?,
        gender: userJson['gender'] as String?,
        displayName: userJson['displayName'] as String?,
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

  @override
  Future<void> saveUserAgreement(UserAgreement agreement) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userAgreementKey, jsonEncode(agreement.toJson()));
  }

  @override
  Future<UserAgreement?> loadUserAgreement() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? agreementJsonString = prefs.getString(_userAgreementKey);

      if (agreementJsonString == null) return null;

      final Map<String, dynamic> agreementJson =
          jsonDecode(agreementJsonString) as Map<String, dynamic>;

      return UserAgreement.fromJson(agreementJson);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUserAgreement() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userAgreementKey);
  }
}
