import 'package:http/http.dart' as http;
import 'package:ridingmate/features/auth/domain/entities/auth_tokens.dart';
import 'package:ridingmate/features/auth/domain/repositories/token_repository.dart';

class AuthorizedHttpClient extends http.BaseClient {
  AuthorizedHttpClient({
    required http.Client inner,
    required TokenRepository tokenRepository,
  }) : _inner = inner,
       _tokenRepository = tokenRepository;

  final http.Client _inner;
  final TokenRepository _tokenRepository;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final AuthTokens? tokens = await _tokenRepository.loadTokens();
    final String? accessToken = tokens?.accessToken;
    final String tokenType = tokens?.tokenType ?? 'Bearer';

    if (accessToken != null && accessToken.isNotEmpty) {
      // 기존에 명시된 Authorization 헤더가 없다면 주입
      request.headers.putIfAbsent(
        'Authorization',
        () => '$tokenType $accessToken',
      );
    }

    return _inner.send(request);
  }
}
