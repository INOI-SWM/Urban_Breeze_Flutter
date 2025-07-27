import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_segment.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_segment_repository.dart';
import 'package:ridingmate/shared/domain/exceptions/base_domain_exception.dart';

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
  CreateRouteUseCase({required RouteSegmentRepository routeRepository})
    : _routeRepository = routeRepository;

  final RouteSegmentRepository _routeRepository;

  Future<RouteResult<RouteSegment>> execute(
    LatLng startPoint,
    LatLng endPoint,
  ) async {
    try {
      final RouteSegment routeData = await _routeRepository.getRouteSegment(
        startPoint,
        endPoint,
      );
      return RouteSuccess<RouteSegment>(routeData);
    } on NetworkException {
      return const RouteFailure<RouteSegment>('네트워크 연결을 확인해주세요');
    } on ValidationException {
      return const RouteFailure<RouteSegment>('경로 데이터가 유효하지 않습니다');
    } catch (e) {
      return const RouteFailure<RouteSegment>('경로 생성에 실패했습니다. 다시 시도해주세요.');
    }
  }
}
