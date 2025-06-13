import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';
import 'package:ridingmate/services/location_service.dart';
import 'package:ridingmate/services/route_service.dart';
import 'package:ridingmate/ui/widgets/map_controls.dart';

class RidingScreen extends StatefulWidget {
  const RidingScreen({super.key});

  @override
  State<RidingScreen> createState() => _RidingScreenState();
}

class _RidingScreenState extends State<RidingScreen> {
  final LatLng initialCenter = const LatLng(37.5665, 126.9780); //서울시청
  final double initialZoom = 16.0;
  LatLng? _currentPosition;
  bool _isLoading = true;
  final MapController _mapController = MapController();
  bool _isButtonPressed = false;
  final List<LatLng> _pins = <LatLng>[];
  final List<List<LatLng>> _routeSegments = <List<LatLng>>[];
  bool _isRouteLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final LatLng? position = await LocationService.getCurrentLocation();
    setState(() {
      _currentPosition = position;
      _isLoading = false;
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
      final List<LatLng> routePoints = await RouteService.getRoute(
        _pins[_pins.length - 2],
        _pins[_pins.length - 1],
      );

      setState(() {
        _routeSegments.add(routePoints);
      });
    } finally {
      setState(() {
        _isRouteLoading = false;
      });
    }
  }

  void _addPin(LatLng position) {
    if (_isButtonPressed && _pins.length < 50) {
      setState(() {
        _pins.add(position);
        if (_pins.length >= 2) {
          _getRoute();
        }
      });
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

  @override
  Widget build(BuildContext context) {
    final String baseUrl =
        dotenv.env['THUNDERFOREST_BASE_URL'] ?? 'fallback_url';
    final String apiKey = dotenv.env['THUNDERFOREST_API_KEY'] ?? 'fallback_key';
    final String fullUrlTemplate = '$baseUrl?apikey=$apiKey';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
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
            if (_routeSegments.isNotEmpty)
              PolylineLayer(
                polylines:
                    _routeSegments.map<Polyline>((List<LatLng> segment) {
                      return Polyline(
                        points: segment,
                        color: context.semanticColor.primaryNormal,
                        strokeWidth: 4.0,
                      );
                    }).toList(),
              ),
            MarkerLayer(
              markers:
                  _pins.asMap().entries.map((MapEntry<int, LatLng> entry) {
                    final int index = entry.key;
                    final LatLng position = entry.value;
                    return Marker(
                      point: position,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              context.semanticColor.accentBackgroundRedOrange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.caption2.regular.copyWith(
                              color: context.semanticColor.staticWhite,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
        if (_isRouteLoading) const Center(child: CircularProgressIndicator()),
        Positioned(
          right: 16,
          bottom: 16,
          child: MapControls(
            isButtonPressed: _isButtonPressed,
            onToggleButton: _toggleButtonState,
            onRemoveLastPin: _removeLastPin,
            onMoveToCurrentLocation: _moveToCurrentLocation,
            hasPins: _pins.isNotEmpty,
          ),
        ),
      ],
    );
  }
}
