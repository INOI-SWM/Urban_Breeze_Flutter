import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

abstract class KakaoAuthDataSource {
  Future<User?> signIn();
  Future<void> signOut();
  Future<User?> getCurrentUser();
  bool get isSignedIn;
}

class KakaoAuthDataSourceImpl implements KakaoAuthDataSource {
  KakaoAuthDataSourceImpl();

  User? _currentUser;

  User? get currentUser => _currentUser;

  @override
  Future<User?> signIn() async {
    try {
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }

      return await _getUserInfo();
    } catch (error) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await UserApi.instance.logout();
      _currentUser = null;
    } catch (error) {
      return;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final User user = await UserApi.instance.me();
      _currentUser = user;
      return user;
    } catch (error) {
      return null;
    }
  }

  @override
  bool get isSignedIn {
    return _currentUser != null;
  }

  Future<User?> _getUserInfo() async {
    try {
      _currentUser = await UserApi.instance.me();
      return _currentUser;
    } catch (error) {
      return null;
    }
  }
}
