import 'package:urban_breeze/features/auth/domain/entities/auth_login_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/auth_tokens.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';

class UrbanBreezeLoginResponseModel {
  const UrbanBreezeLoginResponseModel({
    required this.tokens,
    required this.user,
  });

  factory UrbanBreezeLoginResponseModel.fromApi(
    Map<String, dynamic> json,
    LoginProvider provider,
  ) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? json;
    final Map<String, dynamic> tokenInfo =
        data['tokenInfo'] as Map<String, dynamic>? ?? data;
    final Map<String, dynamic> userInfo =
        data['userInfo'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final AuthTokens tokens = AuthTokens(
      accessToken: (tokenInfo['accessToken'] ?? '').toString(),
      refreshToken: (tokenInfo['refreshToken'] ?? '').toString(),
      tokenType: (tokenInfo['tokenType'] ?? 'Bearer').toString(),
      expiresIn: (tokenInfo['expiresIn'] ?? 0) as int,
      expiresAt:
          DateTime.now()
              .add(Duration(seconds: (tokenInfo['expiresIn'] ?? 0) as int))
              .toUtc(),
    );

    final User user = User(
      uuid: (userInfo['uuid'] ?? userInfo['userId'] ?? '').toString(),
      nickname: (userInfo['nickname'] ?? '').toString(),
      email: (userInfo['email'] ?? '').toString(),
      profileImagePath:
          (userInfo['profileImagePath'] ??
                  userInfo['profileImageUrl'] as String?)
              ?.trim(),
      introduce: (userInfo['introduce'] as String?)?.trim(),
      birthYear: userInfo['birthYear'] as int?,
      gender: (userInfo['gender'] as String?)?.trim(),
      displayName: (userInfo['nickname'] as String?)?.trim(),
      loginProvider: provider,
      isFirstLogin: (userInfo['isFirstLogin'] ?? true) as bool,
    );

    return UrbanBreezeLoginResponseModel(tokens: tokens, user: user);
  }

  final AuthTokens tokens;
  final User user;

  AuthLoginResult toDomain() => AuthLoginResult(tokens: tokens, user: user);
}
