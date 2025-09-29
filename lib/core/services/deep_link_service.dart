import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

/// Deep Link 처리 서비스
class DeepLinkService {
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();
  static final DeepLinkService _instance = DeepLinkService._internal();

  final StreamController<IntegrationCallback> _callbackController =
      StreamController<IntegrationCallback>.broadcast();

  final StreamController<RouteShareCallback> _routeShareController =
      StreamController<RouteShareCallback>.broadcast();

  Stream<IntegrationCallback> get callbackStream => _callbackController.stream;
  Stream<RouteShareCallback> get routeShareStream =>
      _routeShareController.stream;

  /// Deep Link 초기화
  Future<void> initialize() async {
    try {
      final AppLinks appLinks = AppLinks();

      // 앱이 종료된 상태에서 Deep Link로 실행된 경우
      final Uri? initialLink = await appLinks.getInitialLink();
      if (initialLink != null) {
        _processDeepLink(initialLink);
      }

      // 앱이 실행 중일 때 Deep Link 수신
      appLinks.uriLinkStream.listen((Uri link) {
        _processDeepLink(link);
      });
    } catch (e) {
      debugPrint('Deep Link 초기화 오류: $e');
    }
  }

  /// Deep Link 처리
  void _processDeepLink(Uri link) {
    debugPrint('Deep Link 수신: $link');

    if (link.scheme == 'urbanbreeze' && link.host == 'integration') {
      final IntegrationCallback callback = IntegrationCallback.fromUri(link);
      _callbackController.add(callback);
    } else if (link.scheme == 'urbanbreeze' && link.host == 'route') {
      final RouteShareCallback callback = RouteShareCallback.fromUri(link);
      _routeShareController.add(callback);
    } else if (link.scheme.startsWith('kakao') && link.host == 'oauth') {
      // 카카오 OAuth 딥링크는 무시 (카카오 SDK가 자동 처리)
      debugPrint('카카오 OAuth 딥링크 무시: $link');
    } else {
      // 기타 딥링크는 무시
      debugPrint('처리되지 않는 딥링크: $link');
    }
  }

  /// 리소스 정리
  void dispose() {
    _callbackController.close();
    _routeShareController.close();
  }
}

/// 연동 콜백 데이터 모델
class IntegrationCallback {
  const IntegrationCallback({required this.status});

  factory IntegrationCallback.fromUri(Uri uri) {
    final String? status = uri.queryParameters['status'];

    return IntegrationCallback(status: status ?? 'error');
  }

  final String status;

  bool get isSuccess => status == 'success';

  @override
  String toString() {
    return 'IntegrationCallback(status: $status)';
  }
}

/// 경로 공유 콜백 데이터 모델
class RouteShareCallback {
  const RouteShareCallback({required this.routeId});

  factory RouteShareCallback.fromUri(Uri uri) {
    final String? routeId = uri.queryParameters['routeId'];
    return RouteShareCallback(routeId: routeId ?? '');
  }

  final String routeId;

  bool get isValid => routeId.isNotEmpty;

  @override
  String toString() {
    return 'RouteShareCallback(routeId: $routeId)';
  }
}
