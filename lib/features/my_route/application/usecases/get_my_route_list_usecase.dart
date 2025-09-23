import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_filter.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_list.dart';
import 'package:urban_breeze/features/my_route/domain/repositories/my_route_repository.dart';

class GetMyRouteListUseCase {
  const GetMyRouteListUseCase({required MyRouteRepository repository})
    : _repository = repository;

  final MyRouteRepository _repository;

  /// 경로 리스트 조회 (필터, 페이지네이션 포함)
  Future<AppResult<MyRouteList>> execute({MyRouteFilter? filter}) async {
    try {
      // 기본 필터 사용 (정렬: 최신순, 페이지: 0)
      final MyRouteFilter filterModel = filter ?? const MyRouteFilter();

      final MyRouteList routeList = await _repository.getMyRouteList(
        filterModel,
      );
      return AppSuccess<MyRouteList>(routeList);
    } catch (e) {
      return AppFailure<MyRouteList>(NetworkException(e.toString()));
    }
  }
}
