import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

abstract class KakaoAuthDataSource {
  Future<User?> signIn();
  Future<void> signOut();
  Future<void> unlink();
  bool get isSignedIn;
  Future<String?> getAccessToken();
}

class KakaoAuthDataSourceImpl implements KakaoAuthDataSource {
  KakaoAuthDataSourceImpl();

  User? _currentUser;
  OAuthToken? _currentToken;

  User? get currentUser => _currentUser;

  @override
  Future<User?> signIn() async {
    try {
      if (await isKakaoTalkInstalled()) {
        try {
          _currentToken = await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          _currentToken = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        _currentToken = await UserApi.instance.loginWithKakaoAccount();
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
      _currentToken = null;
    } catch (error) {
      return;
    }
  }

  @override
  Future<void> unlink() async {
    try {
      await UserApi.instance.unlink();
      _currentUser = null;
      _currentToken = null;
    } catch (error) {
      // 연결끊기 실패 시에도 로컬 상태는 초기화
      _currentUser = null;
      _currentToken = null;
      rethrow;
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

  @override
  Future<String?> getAccessToken() async {
    try {
      if (_currentToken != null) return _currentToken!.accessToken;
      final OAuthToken? token =
          await TokenManagerProvider.instance.manager.getToken();
      _currentToken = token;
      return token?.accessToken;
    } catch (error) {
      return null;
    }
  }
}
