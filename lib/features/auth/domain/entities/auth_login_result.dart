import 'package:ridingmate/features/auth/domain/entities/auth_tokens.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';

class AuthLoginResult {
  const AuthLoginResult({required this.tokens, required this.user});

  final AuthTokens tokens;
  final User user;
}
