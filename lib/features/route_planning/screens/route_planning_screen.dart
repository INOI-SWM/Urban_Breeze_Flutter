import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/core/design/typography/app_text_style.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/features/route_planning/models/route_data.dart';
import 'package:ridingmate/features/route_planning/services/location_service.dart';
import 'package:ridingmate/features/route_planning/services/route_service.dart';
import 'package:ridingmate/features/route_planning/widgets/route_create_bottom_panel.dart';
import 'package:ridingmate/features/route_planning/widgets/route_creation_actions.dart';
import 'package:ridingmate/shared/widgets/map/route_pin_marker.dart';

class RoutePlanningScreen extends StatefulWidget {
  const RoutePlanningScreen({super.key});

  @override
  State<RoutePlanningScreen> createState() => _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends State<RoutePlanningScreen> {
  static const LatLng _seoulCityHall = LatLng(37.5665, 126.9780);
  static const double _defaultZoom = 16.0;
  static const int _maxPinCount = 50;

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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final LatLng? position = await LocationService.getCurrentLocation();
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

    try {
      final RouteData? result = await RouteService.getRoute(
        _pins[_pins.length - 2],
        _pins[_pins.length - 1],
      );
      if (result != null && result.points.isNotEmpty) {
        setState(() {
          _routeSegments.add(result);
          _pins[_pins.length - 2] = result.points.first;
          _pins[_pins.length - 1] = result.points.last;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRouteLoading = false;
        });
      }
    }
  }

  void _addPin(LatLng position) {
    if (_isButtonPressed && _pins.length < _maxPinCount) {
      final bool shouldGetRoute = _pins.length + 1 >= 2;
      setState(() {
        _pins.add(position);
      });
      if (shouldGetRoute) {
        _getRoute();
      }
    }
  }

  void _removeLastPin() {
    if (_pins.isNotEmpty) {
      setState(() {
        _pins.removeLast();
        if (_pins.length >= 2) {
          _routeSegments.removeLast();
        } else {
          _routeSegments.clear();
        }
      });
    }
  }

  void _enterSaveMode() {
    setState(() {
      _isSaveMode = true;
    });
  }

  void _exitSaveMode() {
    setState(() {
      _isSaveMode = false;
    });
  }

  void _completeRouteSave(String title) {
    // TODO: 실제 경로 저장 로직 구현
    _exitSaveMode();
  }

  double get totalDistance =>
      _routeSegments.fold(0, (double sum, RouteData seg) => sum + seg.distance);
  double get totalDuration =>
      _routeSegments.fold(0, (double sum, RouteData seg) => sum + seg.duration);
  double get totalElevationGain => _routeSegments.fold(
    0,
    (double sum, RouteData seg) => sum + seg.elevationGain,
  );

  String get formattedTotalDistance =>
      (totalDistance / 1000).toStringAsFixed(2);
  String get formattedTotalDuration {
    final int minutes = (totalDuration / 60).floor();
    final int seconds = (totalDuration % 60).round();
    return '$minutes분 $seconds초';
  }

  String get formattedElevationGain => '${totalElevationGain.round()} m';

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

  @override
  Widget build(BuildContext context) {
    final String baseUrl =
        dotenv.env['THUNDERFOREST_BASE_URL'] ?? 'fallback_url';
    final String apiKey = dotenv.env['THUNDERFOREST_API_KEY'] ?? 'fallback_key';
    final String fullUrlTemplate = '$baseUrl?apikey=$apiKey';

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
                  onTap: (_, LatLng position) {
                    _addPin(position);
                  },
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
                        'Maps: © Thunderforest | Data: © OpenStreetMap contributors',
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
