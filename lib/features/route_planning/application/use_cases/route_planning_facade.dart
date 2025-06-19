import 'package:ridingmate/features/route_planning/application/use_cases/create_route_use_case.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/get_current_location_use_case.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/manage_route_pins_use_case.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/route_stats_use_case.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/save_route_use_case.dart';
import 'package:ridingmate/features/route_planning/domain/repositories/route_repository.dart';

class RoutePlanningFacade {
  RoutePlanningFacade({
    required RouteRepository routeRepository,
    int maxPinCount = 50,
  }) : _createRouteUseCase = CreateRouteUseCase(
         routeRepository: routeRepository,
       ),
       _saveRouteUseCase = SaveRouteUseCase(),
       _getCurrentLocationUseCase = GetCurrentLocationUseCase(),
       _manageRoutePinsUseCase = ManageRoutePinsUseCase(
         maxPinCount: maxPinCount,
       ),
       _routeStatsUseCase = RouteStatsUseCase();

  final CreateRouteUseCase _createRouteUseCase;
  final SaveRouteUseCase _saveRouteUseCase;
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final ManageRoutePinsUseCase _manageRoutePinsUseCase;
  final RouteStatsUseCase _routeStatsUseCase;

  CreateRouteUseCase get createRoute => _createRouteUseCase;

  SaveRouteUseCase get saveRoute => _saveRouteUseCase;

  GetCurrentLocationUseCase get getCurrentLocation =>
      _getCurrentLocationUseCase;

  ManageRoutePinsUseCase get managePins => _manageRoutePinsUseCase;

  RouteStatsUseCase get routeStats => _routeStatsUseCase;
}
