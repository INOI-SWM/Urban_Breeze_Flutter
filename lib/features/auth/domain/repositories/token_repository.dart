import 'package:urban_breeze/features/auth/domain/entities/auth_tokens.dart';

abstract class TokenRepository {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> loadTokens();
  Future<void> clearTokens();
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
}
