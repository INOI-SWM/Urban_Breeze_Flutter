import 'dart:async';

import 'package:app_links/app_links.dart';

/// Universal Link 처리 서비스
/// https://urbanbreeze.org 및 https://devlink.urbanbreeze.org 도메인의 링크를 처리합니다.
class UniversalLinkService {
  factory UniversalLinkService() => _instance;
  UniversalLinkService._internal();
  static final UniversalLinkService _instance =
      UniversalLinkService._internal();

  final StreamController<RouteShareCallback> _routeShareController =
      StreamController<RouteShareCallback>.broadcast();

  final StreamController<RecommendedCourseCallback>
  _recommendedCourseController =
      StreamController<RecommendedCourseCallback>.broadcast();

  Stream<RouteShareCallback> get routeShareStream =>
      _routeShareController.stream;
  Stream<RecommendedCourseCallback> get recommendedCourseStream =>
      _recommendedCourseController.stream;

  /// Universal Link 초기화
  Future<void> initialize() async {
    try {
      final AppLinks appLinks = AppLinks();

      // 앱이 종료된 상태에서 Universal Link로 실행된 경우
      final Uri? initialLink = await appLinks.getInitialLink();
      if (initialLink != null) {
        _processLink(initialLink);
      }

      // 앱이 실행 중일 때 Universal Link 수신
      appLinks.uriLinkStream.listen((Uri link) {
        _processLink(link);
      });
    } catch (e) {
      // Universal Link 초기화 오류 처리
    }
  }

  /// Universal Link 처리
  void _processLink(Uri link) {
    // Universal Links 처리 (https://urbanbreeze.org 또는 https://devlink.urbanbreeze.org)
    if (link.scheme == 'https' &&
        (link.host == 'urbanbreeze.org' ||
            link.host == 'devlink.urbanbreeze.org')) {
      // 통합 /share 엔드포인트 처리
      if (link.path.startsWith('/share')) {
        final String? type = link.queryParameters['type'];
        final String? id = link.queryParameters['id'];

        if (type == 'route' && id != null) {
          // route 타입: routeId 파라미터로 변환하여 처리
          final Uri convertedUri = Uri(
            scheme: link.scheme,
            host: link.host,
            path: '/route',
            queryParameters: <String, String>{'routeId': id},
          );
          final RouteShareCallback callback = RouteShareCallback.fromUri(
            convertedUri,
          );
          _routeShareController.add(callback);
        } else if (type == 'course' && id != null) {
          // course 타입: courseId 파라미터로 변환하여 처리
          final Uri convertedUri = Uri(
            scheme: link.scheme,
            host: link.host,
            path: '/course',
            queryParameters: <String, String>{'courseId': id},
          );
          final RecommendedCourseCallback callback =
              RecommendedCourseCallback.fromUri(convertedUri);
          _recommendedCourseController.add(callback);
        }
      }
    }
  }

  /// 리소스 정리
  void dispose() {
    _routeShareController.close();
    _recommendedCourseController.close();
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

/// 추천경로 공유 콜백 데이터 모델
class RecommendedCourseCallback {
  factory RecommendedCourseCallback.fromUri(Uri uri) {
    final String courseId = uri.queryParameters['courseId'] ?? '';
    return RecommendedCourseCallback(courseId: courseId);
  }
  const RecommendedCourseCallback({required this.courseId});

  final String courseId;

  bool get isValid => courseId.isNotEmpty;

  @override
  String toString() {
    return 'RecommendedCourseCallback(courseId: $courseId)';
  }
}
