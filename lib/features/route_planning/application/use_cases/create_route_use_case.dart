import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';

sealed class RouteResult<T> {
  const RouteResult();
}

class RouteSuccess<T> extends RouteResult<T> {
  const RouteSuccess(this.data);
  final T data;
}

class RouteFailure<T> extends RouteResult<T> {
  const RouteFailure(this.message);
  final String message;
}

class CreateRouteUseCase {
  CreateRouteUseCase({required RouteRepository routeRepository})
    : _routeRepository = routeRepository;

  final RouteRepository _routeRepository;

  Future<RouteResult<RouteData>> execute(
    LatLng startPoint,
    LatLng endPoint,
  ) async {
    try {
      final RouteData routeData = await _routeRepository.getRoute(
        startPoint,
        endPoint,
      );
      return RouteSuccess<RouteData>(routeData);
    } on RouteNetworkException {
      return const RouteFailure<RouteData>('인터넷 연결을 확인해주세요.');
    } on RouteValidationException {
      return const RouteFailure<RouteData>('유효하지 않은 경로입니다. 다른 위치를 시도해보세요.');
    } catch (e) {
      //TODO : CATCH 하지 않은 예외, LOGGING등 적용
      return const RouteFailure<RouteData>('경로 생성에 실패했습니다. 다시 시도해주세요.');
    }
  }
}
