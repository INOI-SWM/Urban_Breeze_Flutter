import 'package:ridingmate/features/my_route/data/models/route_filter_model.dart';
import 'package:ridingmate/features/my_route/data/models/route_list_data_model.dart';
import 'package:ridingmate/features/my_route/data/models/route_model.dart';
import 'package:ridingmate/features/my_route/domain/repositories/route_repository.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

class GetRouteListUseCase {
  const GetRouteListUseCase({required RouteRepository repository})
    : _repository = repository;

  final RouteRepository _repository;

  Future<List<RouteModel>> execute({RouteFilterModel? filter}) async {
    try {
      final RouteFilterModel filterModel = filter ?? const RouteFilterModel();
      final ApiResponseModel<RouteListDataModel> response = await _repository
          .getRouteList(filterModel);
      return response.data.routes;
    } catch (e) {
      // 에러 발생 시 빈 리스트 반환
      return <RouteModel>[];
    }
  }
}
