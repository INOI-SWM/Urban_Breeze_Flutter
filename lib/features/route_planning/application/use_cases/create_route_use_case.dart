import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_segment.dart';
import 'package:ridingmate/features/route_planning/domain/exceptions/route_domain_exceptions.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_segment_repository.dart';

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
    } on RouteNetworkException {
      return const RouteFailure<RouteSegment>('인터넷 연결을 확인해주세요.');
    } on RouteValidationException {
      return const RouteFailure<RouteSegment>('유효하지 않은 경로입니다. 다른 위치를 시도해보세요.');
    } catch (e) {
      //TODO : CATCH 하지 않은 예외, LOGGING등 적용
      return const RouteFailure<RouteSegment>('경로 생성에 실패했습니다. 다시 시도해주세요.');
    }
  }
}
