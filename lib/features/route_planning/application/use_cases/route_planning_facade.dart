import 'package:urban_breeze/features/route_planning/application/use_cases/create_route_use_case.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/fit_map_to_routes_use_case.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/get_current_location_use_case.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/manage_route_pins_use_case.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/route_stats_use_case.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/save_route_use_case.dart';

class RoutePlanningFacade {
  const RoutePlanningFacade({
    required CreateRouteUseCase createRouteUseCase,
    required SaveRouteUseCase saveRouteUseCase,
    required GetCurrentLocationUseCase getCurrentLocationUseCase,
    required ManageRoutePinsUseCase manageRoutePinsUseCase,
    required RouteStatsUseCase routeStatsUseCase,
    required FitMapToRoutesUseCase fitMapToRoutesUseCase,
  }) : _createRouteUseCase = createRouteUseCase,
       _saveRouteUseCase = saveRouteUseCase,
       _getCurrentLocationUseCase = getCurrentLocationUseCase,
       _manageRoutePinsUseCase = manageRoutePinsUseCase,
       _routeStatsUseCase = routeStatsUseCase,
       _fitMapToRoutesUseCase = fitMapToRoutesUseCase;

  final CreateRouteUseCase _createRouteUseCase;
  final SaveRouteUseCase _saveRouteUseCase;
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  final ManageRoutePinsUseCase _manageRoutePinsUseCase;
  final RouteStatsUseCase _routeStatsUseCase;
  final FitMapToRoutesUseCase _fitMapToRoutesUseCase;

  CreateRouteUseCase get createRoute => _createRouteUseCase;

  SaveRouteUseCase get saveRoute => _saveRouteUseCase;

  GetCurrentLocationUseCase get getCurrentLocation =>
      _getCurrentLocationUseCase;

  ManageRoutePinsUseCase get managePins => _manageRoutePinsUseCase;

  RouteStatsUseCase get routeStats => _routeStatsUseCase;

  FitMapToRoutesUseCase get fitMapToRoutes => _fitMapToRoutesUseCase;
}
