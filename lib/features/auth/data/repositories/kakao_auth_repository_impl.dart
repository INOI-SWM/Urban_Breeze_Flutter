import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:urban_breeze/features/auth/data/datasources/kakao_auth_datasource.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';
import 'package:urban_breeze/features/auth/domain/repositories/kakao_auth_repository.dart';

class KakaoAuthRepositoryImpl implements KakaoAuthRepository {
  KakaoAuthRepositoryImpl({required KakaoAuthDataSource kakaoAuthDataSource})
    : _kakaoAuthDataSource = kakaoAuthDataSource;

  final KakaoAuthDataSource _kakaoAuthDataSource;

  @override
  Future<User?> signIn() async {
    final kakao.User? kakaoUser = await _kakaoAuthDataSource.signIn();
    if (kakaoUser == null) return null;

    return _mapKakaoUserToUser(kakaoUser);
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
  Future<User?> getCurrentUser() async {
    final kakao.User? kakaoUser = await _kakaoAuthDataSource.getCurrentUser();
    if (kakaoUser == null) return null;

    return _mapKakaoUserToUser(kakaoUser);
  }

  @override
  bool get isSignedIn => _kakaoAuthDataSource.isSignedIn;

  @override
  Future<String?> getAccessToken() => _kakaoAuthDataSource.getAccessToken();

  User _mapKakaoUserToUser(kakao.User kakaoUser) {
    return User(
      uuid: kakaoUser.id.toString(),
      nickname: kakaoUser.kakaoAccount?.profile?.nickname ?? 'Kakao User',
      email: kakaoUser.kakaoAccount?.email ?? '',
      profileImagePath: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
      displayName: kakaoUser.kakaoAccount?.profile?.nickname,
      loginProvider: LoginProvider.kakao,
    );
  }
}
