import 'package:urban_breeze/features/auth/domain/entities/auth_login_result.dart';
import 'package:urban_breeze/features/auth/domain/entities/auth_tokens.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/entities/user_agreement.dart';
import 'package:urban_breeze/features/auth/domain/enums/login_provider.dart';

class UrbanBreezeLoginResponseModel {
  const UrbanBreezeLoginResponseModel({
    required this.tokens,
    required this.user,
    required this.agreement,
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
    final Map<String, dynamic> agreementStatus =
        data['agreementStatus'] as Map<String, dynamic>? ?? <String, dynamic>{};

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
      profileImageUrl:
          (userInfo['profileImageUrl'] ??
                  userInfo['profileImageUrl'] as String?)
              ?.trim(),
      introduce: (userInfo['introduce'] as String?)?.trim(),
      birthYear: userInfo['birthYear'] as int?,
      gender: (userInfo['gender'] as String?)?.trim(),
      displayName: (userInfo['nickname'] as String?)?.trim(),
      loginProvider: provider,
      isFirstLogin: (userInfo['isFirstLogin'] ?? true) as bool,
    );

    final UserAgreement agreement = UserAgreement(
      termsOfServiceAgreed:
          agreementStatus['termsOfServiceAgreed'] as bool? ?? false,
      privacyPolicyAgreed:
          agreementStatus['privacyPolicyAgreed'] as bool? ?? false,
      locationServiceAgreed:
          agreementStatus['locationServiceAgreed'] as bool? ?? false,
      isCompleted: agreementStatus['isCompleted'] as bool? ?? false,
    );

    return UrbanBreezeLoginResponseModel(
      tokens: tokens,
      user: user,
      agreement: agreement,
    );
  }

  final AuthTokens tokens;
  final User user;
  final UserAgreement agreement;

  AuthLoginResult toDomain() =>
      AuthLoginResult(tokens: tokens, user: user, agreement: agreement);
}
