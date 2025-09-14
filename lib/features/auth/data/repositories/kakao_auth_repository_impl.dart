import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:urban_breeze/features/auth/data/datasources/kakao_auth_datasource.dart';
import 'package:urban_breeze/features/auth/domain/repositories/kakao_auth_repository.dart';

class KakaoAuthRepositoryImpl implements KakaoAuthRepository {
  KakaoAuthRepositoryImpl({required KakaoAuthDataSource kakaoAuthDataSource})
    : _kakaoAuthDataSource = kakaoAuthDataSource;

  final KakaoAuthDataSource _kakaoAuthDataSource;

  @override
  Future<bool> signIn() async {
    try {
      final kakao.User? kakaoUser = await _kakaoAuthDataSource.signIn();
      return kakaoUser != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    await _kakaoAuthDataSource.signOut();
  }

  @override
  Future<void> withdraw() async {
    await _kakaoAuthDataSource.unlink();
  }

  @override
  bool get isSignedIn => _kakaoAuthDataSource.isSignedIn;

  @override
  Future<String?> getAccessToken() => _kakaoAuthDataSource.getAccessToken();
}
