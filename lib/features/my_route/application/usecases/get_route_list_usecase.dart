import 'package:ridingmate/core/exceptions/base_domain_exception.dart';
import 'package:ridingmate/core/result/app_result.dart';
import 'package:ridingmate/features/my_route/data/mappers/route_mapper.dart';
import 'package:ridingmate/features/my_route/data/models/route_filter_model.dart';
import 'package:ridingmate/features/my_route/domain/entities/route_filter.dart';
import 'package:ridingmate/features/my_route/domain/entities/route_list.dart';
import 'package:ridingmate/features/my_route/domain/enums/route_sort_type.dart';
import 'package:ridingmate/features/my_route/domain/repositories/route_repository.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';

class GetRouteListUseCase {
  const GetRouteListUseCase({required RouteRepository repository})
    : _repository = repository;

  final RouteRepository _repository;

  Future<AppResult<MyRouteList>> execute({
    MyRouteFilter? filter,
    FilterData? filterData,
    RouteSortType? sortType,
  }) async {
    try {
      MyRouteFilter filterModel;

      if (filter != null) {
        // 직접 MyRouteFilter가 제공된 경우
        filterModel = filter;
      } else if (filterData != null && sortType != null) {
        // UI 필터 데이터가 제공된 경우, RouteMapper를 통해 변환
        final RouteFilterModel apiFilter = RouteMapper.fromFilterData(
          filterData,
          sortType,
        );
        filterModel = RouteMapper.fromFilterModel(apiFilter);
      } else {
        // 기본 필터 사용
        filterModel = const MyRouteFilter();
      }

      final MyRouteList routeList = await _repository.getRouteList(filterModel);
      return AppSuccess<MyRouteList>(routeList);
    } catch (e) {
      return AppFailure<MyRouteList>(NetworkException(e.toString()));
    }
  }
}
