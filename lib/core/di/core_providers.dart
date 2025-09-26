import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/domain/repositories/token_repository.dart';
import 'package:urban_breeze/shared/api/data/http/authorized_http_client.dart';

final Provider<http.Client> httpClientProvider = Provider<http.Client>((
  Ref<http.Client> ref,
) {
  final http.Client client = http.Client();
  ref.onDispose(() => client.close());
  return client;
});

// 인증 헤더 자동 주입 클라이언트
final Provider<http.Client> authorizedHttpClientProvider =
    Provider<http.Client>((Ref<http.Client> ref) {
      final http.Client inner = ref.watch(httpClientProvider);
      final TokenRepository tokenRepository = ref.watch(
        tokenRepositoryProvider,
      );
      return AuthorizedHttpClient(
        inner: inner,
        tokenRepository: tokenRepository,
        // onAuthFailure 제거: 앱 시작 시 loadUserSession()에서 토큰 검증하도록 변경
        onAuthFailure: null,
      );
    });
