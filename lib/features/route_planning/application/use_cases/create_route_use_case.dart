import 'package:latlong2/latlong.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_segment.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_segment_repository.dart';
import 'package:ridingmate/core/result/app_result.dart';
import 'package:ridingmate/core/exceptions/base_domain_exception.dart';

class CreateRouteUseCase {
  CreateRouteUseCase({required RouteSegmentRepository routeRepository})
    : _routeRepository = routeRepository;

  final RouteSegmentRepository _routeRepository;

  Future<AppResult<RouteSegment>> execute(
    LatLng startPoint,
    LatLng endPoint,
  ) async {
    try {
      final RouteSegment routeData = await _routeRepository.getRouteSegment(
        startPoint,
        endPoint,
      );
      return AppSuccess<RouteSegment>(routeData);
    } on NetworkException catch (e) {
      return AppFailure<RouteSegment>(e);
    } on ValidationException catch (e) {
      return AppFailure<RouteSegment>(e);
    } catch (e) {
      return const AppFailure<RouteSegment>(
        ParsingException('경로 생성에 실패했습니다. 다시 시도해주세요.'),
      );
    }
  }
}
