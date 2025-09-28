import 'package:urban_breeze/features/auth/domain/entities/auth_tokens.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/entities/user_agreement.dart';

class AuthLoginResult {
  const AuthLoginResult({
    required this.tokens,
    required this.user,
    required this.agreement,
  });

  final AuthTokens tokens;
  final User user;
  final UserAgreement agreement;
}
