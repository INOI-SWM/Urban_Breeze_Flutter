import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/create_route_use_case.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/route_planning_facade.dart';
import 'package:ridingmate/features/route_planning/di/route_providers.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_data.dart';
import 'package:ridingmate/features/route_planning/domain/services/bbox_service.dart';
import 'package:ridingmate/features/route_planning/presentation/widgets/route_create_bottom_panel.dart';
import 'package:ridingmate/features/route_planning/presentation/widgets/route_creation_actions.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/marker/route_pin_marker.dart';

class RoutePlanningScreen extends ConsumerStatefulWidget {
  const RoutePlanningScreen({super.key});

  @override
  ConsumerState<RoutePlanningScreen> createState() =>
      _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends ConsumerState<RoutePlanningScreen> {
  static const LatLng _seoulCityHall = LatLng(37.5665, 126.9780);
  static const double _defaultZoom = 16.0;

  final LatLng initialCenter = _seoulCityHall;
  final double initialZoom = _defaultZoom;

  LatLng? _currentPosition;
  bool _isLocationLoading = true;

  final MapController _mapController = MapController();

  bool _isButtonPressed = false;
  final List<LatLng> _pins = <LatLng>[];
  final List<RouteData> _routeSegments = <RouteData>[];
  bool _isRouteLoading = false;
  bool _isSaveMode = false;

  late final RoutePlanningFacade _facade;

  @override
  void initState() {
    super.initState();
    _facade = ref.read(routePlanningFacadeProvider);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final LatLng? position = await _facade.getCurrentLocation.execute();
    setState(() {
      _currentPosition = position;
      _isLocationLoading = false;
    });
  }

  void _moveToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, initialZoom);
    }
  }

  void _toggleButtonState() {
    setState(() {
      _isButtonPressed = !_isButtonPressed;
    });
  }

  Future<void> _getRoute() async {
    if (_pins.length < 2) return;

    setState(() {
      _isRouteLoading = true;
    });

    final RouteResult<RouteData> result = await _facade.createRoute.execute(
      _pins[_pins.length - 2],
      _pins[_pins.length - 1],
    );

    if (mounted) {
      setState(() {
        _isRouteLoading = false;
      });

      switch (result) {
        case final RouteSuccess<RouteData> success:
          setState(() {
            _routeSegments.add(success.data);
            _pins[_pins.length - 2] = success.data.points.first;
            _pins[_pins.length - 1] = success.data.points.last;
          });
        case final RouteFailure<RouteData> failure:
          _removeLastPin(shouldRemoveRouteSegment: false);
          _showErrorSnackBar(failure.message);
      }
    }
  }

  void _addPin(LatLng position) {
    if (_isRouteLoading) return;

    if (_facade.managePins.shouldAddPin(_isButtonPressed, _pins)) {
      setState(() {
        _pins.add(position);
      });
      if (_facade.managePins.shouldGetRoute(_pins)) {
        _getRoute();
      }
    }
  }

  void _removeLastPin({bool shouldRemoveRouteSegment = true}) {
    setState(() {
      _pins.removeLast();

      if (shouldRemoveRouteSegment) {
        // 사용자가 직접 핀을 제거하는 경우
        if (_pins.length >= 2) {
          _routeSegments.removeLast();
        } else {
          _routeSegments.clear();
        }
      }
    });
  }

  void _fitMapToAllRoutes() {
    final List<List<double>?> allBboxes =
        _routeSegments.map((RouteData segment) => segment.bbox).toList();

    final List<double>? mergedBbox = BboxService.mergeBboxes(allBboxes);

    if (mergedBbox != null) {
      final List<double> expandedBbox = BboxService.expandBbox(
        mergedBbox,
        paddingRatio: 0.3,
      );

      final LatLngBounds bounds = LatLngBounds(
        LatLng(expandedBbox[1], expandedBbox[0]),
        LatLng(expandedBbox[3], expandedBbox[2]),
      );

      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(20)),
      );
    }
  }

  void _enterSaveMode() {
    _fitMapToAllRoutes();
    setState(() {
      _isSaveMode = true;
    });
  }

  void _exitSaveMode() {
    setState(() {
      _isSaveMode = false;
    });
  }

  Future<void> _completeRouteSave(String title) async {
    await _facade.saveRoute.execute(_routeSegments, title);
    _exitSaveMode();
  }

  String get formattedTotalDistance =>
      _facade.routeStats.getFormattedTotalDistance(_routeSegments);
  String get formattedTotalDuration =>
      _facade.routeStats.getFormattedTotalDuration(_routeSegments);
  String get formattedElevationGain =>
      _facade.routeStats.getFormattedElevationGain(_routeSegments);

  Widget _buildBottomBar() {
    return RouteCreateBottomPanel(
      mode: _isSaveMode ? RouteCreateMode.save : RouteCreateMode.create,
      totalDistance: formattedTotalDistance,
      totalDuration: formattedTotalDuration,
      elevationGain: formattedElevationGain,
      hasRoute: _routeSegments.isNotEmpty,
      onSave: _enterSaveMode,
      onBack: _exitSaveMode,
      onComplete: _completeRouteSave,
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String baseUrl = dotenv.env['GEOAPIFY_BASE_URL'] ?? 'fallback_url';
    final String apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? 'fallback_key';
    final String fullUrlTemplate = '$baseUrl?&apiKey=$apiKey';

    if (_isLocationLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: <Widget>[
        Expanded(
          child: Stack(
            children: <Widget>[
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition ?? initialCenter,
                  initialZoom: initialZoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  onTap:
                      _isSaveMode
                          ? null
                          : (_, LatLng position) => _addPin(position),
                ),
                children: <Widget>[
                  TileLayer(
                    urlTemplate: fullUrlTemplate,
                    userAgentPackageName: 'com.example.ridingmate',
                    subdomains: const <String>['a', 'b', 'c'],
                  ),
                  RichAttributionWidget(
                    alignment: AttributionAlignment.bottomLeft,
                    showFlutterMapAttribution: false,
                    attributions: <SourceAttribution>[
                      TextSourceAttribution(
                        'Powered by Geoapify | © OpenStreetMap contributors',
                        textStyle: AppTextStyles.caption2.regular,
                      ),
                    ],
                  ),
                  if (_currentPosition != null)
                    MarkerLayer(
                      markers: <Marker>[
                        Marker(
                          point: _currentPosition!,
                          width: 32,
                          height: 32,
                          child: Image.asset(
                            'assets/icons/png/current_location_pin.png',
                          ),
                        ),
                      ],
                    ),
                  PolylineLayer<Object>(
                    polylines:
                        _routeSegments
                            .map(
                              (RouteData segment) => Polyline<Object>(
                                points: segment.points,
                                color: context.semanticColor.primaryNormal,
                                strokeWidth: 4.0,
                              ),
                            )
                            .toList(),
                  ),
                  MarkerLayer(
                    markers:
                        _pins.asMap().entries.map((
                          MapEntry<int, LatLng> entry,
                        ) {
                          final int index = entry.key;
                          final LatLng position = entry.value;
                          return Marker(
                            point: position,
                            width: 24,
                            height: 24,
                            child: RoutePinMarker(index: index),
                          );
                        }).toList(),
                  ),
                ],
              ),
              if (_isRouteLoading)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                ),
              Positioned(
                right: 16,
                bottom: 16,
                child: RouteCreationActionButtons(
                  isPinButtonPressed: _isButtonPressed,
                  onTogglePinButton: _toggleButtonState,
                  onRemoveLastPin: _removeLastPin,
                  onMoveToCurrentLocation: _moveToCurrentLocation,
                  hasPins: _pins.isNotEmpty,
                ),
              ),
            ],
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }
}
