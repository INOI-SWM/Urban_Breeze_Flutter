import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/route_sharing/domain/entities/route_share_link.dart';
import 'package:urban_breeze/features/route_sharing/domain/repositories/route_share_repository.dart';

class GetRouteShareLinkUseCase {
  const GetRouteShareLinkUseCase({required RouteShareRepository repository})
    : _repository = repository;

  final RouteShareRepository _repository;

  Future<AppResult<RouteShareLink>> execute(String routeId) async {
    try {
      final RouteShareLink link = await _repository.getShareLink(routeId);

      // 링크 생성 성공 이벤트
      AmplitudeAnalytics.logEvent(
        'route_sharing_link_generated',
        properties: <String, dynamic>{
          'route_id': routeId,
          'share_url': link.url,
        },
      );

      return AppSuccess<RouteShareLink>(link);
    } catch (e) {
      // 링크 생성 실패 이벤트
      AmplitudeAnalytics.logEvent(
        'route_sharing_link_generation_failed',
        properties: <String, dynamic>{
          'route_id': routeId,
          'error_message': e.toString(),
        },
      );

      return AppFailure<RouteShareLink>(NetworkException(e.toString()));
    }
  }
}
