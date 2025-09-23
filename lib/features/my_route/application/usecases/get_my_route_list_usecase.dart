import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_filter.dart';
import 'package:urban_breeze/features/my_route/domain/entities/my_route_list.dart';
import 'package:urban_breeze/features/my_route/domain/enums/my_route_sort_type.dart';
import 'package:urban_breeze/features/my_route/domain/repositories/my_route_repository.dart';
import 'package:urban_breeze/shared/filter/models/filter_data.dart';

class GetMyRouteListUseCase {
  const GetMyRouteListUseCase({required MyRouteRepository repository})
    : _repository = repository;

  final MyRouteRepository _repository;

  /// 초기 로딩용 - 필터 없이 기본 조회
  Future<AppResult<MyRouteList>> executeInitial({
    MyRouteSortType sortType = MyRouteSortType.newest,
  }) async {
    try {
      final MyRouteFilter filterModel = MyRouteFilter(sortType: sortType);
      final MyRouteList routeList = await _repository.getMyRouteList(
        filterModel,
      );
      return AppSuccess<MyRouteList>(routeList);
    } catch (e) {
      return AppFailure<MyRouteList>(NetworkException(e.toString()));
    }
  }

  /// 필터 적용 조회
  Future<AppResult<MyRouteList>> execute({
    MyRouteFilter? filter,
    FilterData? filterData,
    MyRouteSortType? sortType,
  }) async {
    try {
      MyRouteFilter filterModel;

      if (filter != null) {
        // 직접 MyRouteFilter가 제공된 경우
        filterModel = filter;
      } else if (filterData != null && sortType != null) {
        // UI 필터 데이터가 제공된 경우, Domain Layer에서 변환
        filterModel = MyRouteFilter.fromFilterData(filterData, sortType);
      } else {
        // 기본 필터 사용
        filterModel = const MyRouteFilter();
      }

      final MyRouteList routeList = await _repository.getMyRouteList(
        filterModel,
      );
      return AppSuccess<MyRouteList>(routeList);
    } catch (e) {
      return AppFailure<MyRouteList>(NetworkException(e.toString()));
    }
  }

  /// 다음 페이지 로드 (무한스크롤용)
  Future<AppResult<MyRouteList>> executeLoadMore({
    required MyRouteFilter currentFilter,
    required int nextPage,
  }) async {
    try {
      final MyRouteFilter nextPageFilter = currentFilter.copyWith(
        page: nextPage,
      );

      final MyRouteList routeList = await _repository.getMyRouteList(
        nextPageFilter,
      );
      return AppSuccess<MyRouteList>(routeList);
    } catch (e) {
      return AppFailure<MyRouteList>(NetworkException(e.toString()));
    }
  }
}
