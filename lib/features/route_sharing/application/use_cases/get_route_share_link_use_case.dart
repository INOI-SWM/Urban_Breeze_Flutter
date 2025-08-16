import 'package:ridingmate/core/exceptions/base_domain_exception.dart';
import 'package:ridingmate/core/result/app_result.dart';
import 'package:ridingmate/features/route_sharing/domain/entities/route_share_link.dart';
import 'package:ridingmate/features/route_sharing/domain/repositories/route_share_repository.dart';

class GetRouteShareLinkUseCase {
  const GetRouteShareLinkUseCase({required RouteShareRepository repository})
    : _repository = repository;

  final RouteShareRepository _repository;

  Future<AppResult<RouteShareLink>> execute(String routeId) async {
    try {
      final RouteShareLink link = await _repository.getShareLink(routeId);
      return AppSuccess<RouteShareLink>(link);
    } catch (e) {
      return AppFailure<RouteShareLink>(NetworkException(e.toString()));
    }
  }
}
