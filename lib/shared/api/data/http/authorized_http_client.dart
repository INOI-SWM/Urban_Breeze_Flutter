import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ridingmate/features/auth/domain/entities/auth_tokens.dart';
import 'package:ridingmate/features/auth/domain/repositories/token_repository.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';

typedef OnAuthFailure = FutureOr<void> Function();

class AuthorizedHttpClient extends http.BaseClient {
  AuthorizedHttpClient({
    required http.Client inner,
    required TokenRepository tokenRepository,
    OnAuthFailure? onAuthFailure,
  }) : _inner = inner,
       _tokenRepository = tokenRepository,
       _onAuthFailure = onAuthFailure;

  final http.Client _inner;
  final TokenRepository _tokenRepository;
  final OnAuthFailure? _onAuthFailure;

  Future<bool>? _ongoingRefresh;
  static const String _retryHeader = 'X-Auth-Retry';
  static const String _refreshEndpoint = '/api/auth/refresh';

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 인증 헤더 자동 주입
    final AuthTokens? tokens = await _tokenRepository.loadTokens();
    final String? accessToken = tokens?.accessToken;
    final String tokenType = tokens?.tokenType ?? 'Bearer';
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers.putIfAbsent(
        'Authorization',
        () => '$tokenType $accessToken',
      );
    }

    // 원본 요청을 복제할 수 있도록 사전 스냅샷 생성
    final _ClonedRequestBuilder? cloneBuilder = _cloneIfPossible(request);

    http.StreamedResponse response = await _inner.send(request);

    // 이미 재시도한 요청은 더 이상 리프레시 시도하지 않음
    final bool alreadyRetried = request.headers[_retryHeader] == '1';

    if (!alreadyRetried && response.statusCode == 401 && cloneBuilder != null) {
      final bool refreshed = await _refreshTokens();
      if (refreshed) {
        final http.BaseRequest retryReq = cloneBuilder();
        retryReq.headers[_retryHeader] = '1';
        // 최신 토큰 주입
        final AuthTokens? newTokens = await _tokenRepository.loadTokens();
        final String? newAccess = newTokens?.accessToken;
        final String newType = newTokens?.tokenType ?? 'Bearer';
        if (newAccess != null && newAccess.isNotEmpty) {
          retryReq.headers['Authorization'] = '$newType $newAccess';
        }
        response = await _inner.send(retryReq);
      }
    }

    return response;
  }

  _ClonedRequestBuilder? _cloneIfPossible(http.BaseRequest request) {
    if (request is http.Request) {
      final Uri url = request.url;
      final String method = request.method;
      final Map<String, String> headers = Map<String, String>.from(
        request.headers,
      );
      final List<int> bodyBytes = request.bodyBytes;
      return () {
        final http.Request r = http.Request(method, url);
        r.headers.addAll(headers);
        r.bodyBytes = bodyBytes;
        return r;
      };
    }
    // MultipartRequest 등은 안전하게 복제 어려움 → 리프레시 재시도 생략
    return null;
  }

  Future<bool> _refreshTokens() async {
    // 중복 갱신 제어
    if (_ongoingRefresh != null) {
      try {
        return await _ongoingRefresh!;
      } catch (_) {
        return false;
      }
    }

    final Completer<bool> completer = Completer<bool>();
    _ongoingRefresh = completer.future;

    try {
      final String? refreshToken = await _tokenRepository.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        // 리프레시 토큰 자체가 없으면 세션 종료 상태로 간주
        await _tokenRepository.clearTokens();
        completer.complete(false);
        return false;
      }

      final Uri uri = Uri.parse(
        '${BaseRemoteDataSource.baseUrl}$_refreshEndpoint',
      );
      final http.Request req = http.Request('POST', uri);
      req.headers['Content-Type'] = 'application/json; charset=utf-8';
      req.body = jsonEncode(<String, dynamic>{'refreshToken': refreshToken});

      final http.StreamedResponse streamed = await _inner.send(req);
      final http.Response resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final Map<String, dynamic> jsonMap =
            json.decode(resp.body) as Map<String, dynamic>;
        final Map<String, dynamic> data =
            (jsonMap['data'] as Map<String, dynamic>?) ?? jsonMap;
        final Map<String, dynamic> tokenInfo =
            (data['tokenInfo'] as Map<String, dynamic>?) ?? data;

        final AuthTokens tokens = AuthTokens(
          accessToken: (tokenInfo['accessToken'] ?? '').toString(),
          refreshToken: (tokenInfo['refreshToken'] ?? '').toString(),
          tokenType: (tokenInfo['tokenType'] ?? 'Bearer').toString(),
          expiresIn: (tokenInfo['expiresIn'] ?? 0) as int,
        );
        await _tokenRepository.saveTokens(tokens);
        completer.complete(true);
        return true;
      } else if (resp.statusCode == 401 || resp.statusCode == 403) {
        // 리프레시 토큰 만료/무효 → 토큰 정리 후 실패 반환
        await _tokenRepository.clearTokens();
        final OnAuthFailure? onFail = _onAuthFailure;
        if (onFail != null) {
          await onFail();
        }
        completer.complete(false);
        return false;
      }
    } catch (_) {
      // ignore
    } finally {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      _ongoingRefresh = null;
    }
    return false;
  }

}

typedef _ClonedRequestBuilder = http.BaseRequest Function();
