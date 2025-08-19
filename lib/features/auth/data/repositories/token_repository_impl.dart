import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:urban_breeze/features/auth/domain/entities/auth_tokens.dart';
import 'package:urban_breeze/features/auth/domain/repositories/token_repository.dart';

class TokenRepositoryImpl implements TokenRepository {
  TokenRepositoryImpl({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _key = 'rm.tokens.v1';

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    final Map<String, dynamic> map = <String, dynamic>{
      'accessToken': tokens.accessToken,
      'refreshToken': tokens.refreshToken,
      'tokenType': tokens.tokenType,
      'expiresIn': tokens.expiresIn,
      'expiresAt': tokens.expiresAt.toIso8601String(),
    };
    await _storage.write(key: _key, value: jsonEncode(map));
  }

  @override
  Future<AuthTokens?> loadTokens() async {
    final String? jsonStr = await _storage.read(key: _key);
    if (jsonStr == null) return null;
    try {
      final Map<String, dynamic> map =
          jsonDecode(jsonStr) as Map<String, dynamic>;
      return AuthTokens(
        accessToken: map['accessToken'] as String? ?? '',
        refreshToken: map['refreshToken'] as String? ?? '',
        tokenType: map['tokenType'] as String? ?? 'Bearer',
        expiresIn: map['expiresIn'] as int? ?? 0,
        expiresAt:
            DateTime.tryParse(map['expiresAt'] as String) ?? DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _key);
  }

  @override
  Future<String?> getAccessToken() async {
    final AuthTokens? t = await loadTokens();
    return t?.accessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    final AuthTokens? t = await loadTokens();
    return t?.refreshToken;
  }
}
