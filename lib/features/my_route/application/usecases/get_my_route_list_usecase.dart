import 'package:ridingmate/core/exceptions/base_domain_exception.dart';
import 'package:ridingmate/core/result/app_result.dart';
import 'package:ridingmate/features/my_route/data/mappers/my_route_mapper.dart';
import 'package:ridingmate/features/my_route/data/models/my_route_filter_model.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route_filter.dart';
import 'package:ridingmate/features/my_route/domain/entities/my_route_list.dart';
import 'package:ridingmate/features/my_route/domain/enums/my_route_sort_type.dart';
import 'package:ridingmate/features/my_route/domain/repositories/my_route_repository.dart';
import 'package:ridingmate/shared/filter/models/filter_data.dart';

class GetMyRouteListUseCase {
  const GetMyRouteListUseCase({required MyRouteRepository repository})
    : _repository = repository;

  final MyRouteRepository _repository;

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
        // UI 필터 데이터가 제공된 경우, MyRouteMapper를 통해 변환
        final MyRouteFilterModel apiFilter = MyRouteMapper.fromFilterData(
          filterData,
          sortType,
        );
        filterModel = MyRouteMapper.fromFilterModel(apiFilter);
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
}
