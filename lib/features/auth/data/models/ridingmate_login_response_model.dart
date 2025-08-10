import 'package:ridingmate/features/auth/domain/entities/auth_login_result.dart';
import 'package:ridingmate/features/auth/domain/entities/auth_tokens.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/auth/domain/enums/login_provider.dart';

class RidingMateLoginResponseModel {
  const RidingMateLoginResponseModel({
    required this.tokens,
    required this.user,
  });

  factory RidingMateLoginResponseModel.fromApi(
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
    );

    final User user = User(
      id: (userInfo['userId'] ?? '').toString(),
      email: (userInfo['email'] ?? '').toString(),
      displayName: (userInfo['nickname'] as String?)?.trim(),
      photoUrl: (userInfo['profileImageUrl'] as String?)?.trim(),
      loginProvider: provider,
    );

    return RidingMateLoginResponseModel(tokens: tokens, user: user);
  }

  final AuthTokens tokens;
  final User user;

  AuthLoginResult toDomain() => AuthLoginResult(tokens: tokens, user: user);
}
