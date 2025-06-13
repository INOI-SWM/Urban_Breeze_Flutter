import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/core/theme/extensions.dart';
import 'package:ridingmate/design_system/map/route_pin_marker.dart';
import 'package:ridingmate/design_system/typography/app_text_style.dart';
import 'package:ridingmate/models/route_result.dart';
import 'package:ridingmate/services/location_service.dart';
import 'package:ridingmate/services/route_service.dart';
import 'package:ridingmate/ui/widgets/route_creation_actions.dart';

class RidingScreen extends StatefulWidget {
  const RidingScreen({super.key});

  @override
  State<RidingScreen> createState() => _RidingScreenState();
}

class _RidingScreenState extends State<RidingScreen> {
  final LatLng initialCenter = const LatLng(37.5665, 126.9780); //서울시청
  final double initialZoom = 16.0;

  LatLng? _currentPosition;
  bool _isLocationLoading = true;

  final MapController _mapController = MapController();

  bool _isButtonPressed = false;
  final List<LatLng> _pins = <LatLng>[];
  final List<RouteResult> _routeSegments = <RouteResult>[];
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
      final RouteResult? result = await RouteService.getRoute(
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
      setState(() {
        _isRouteLoading = false;
      });
    }
  }

  void _addPin(LatLng position) {
    if (_isButtonPressed && _pins.length < 50) {
      bool shouldGetRoute = false;
      setState(() {
        _pins.add(position);
        shouldGetRoute = _pins.length >= 2;
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

  double get totalDistance => _routeSegments.fold(
    0,
    (double sum, RouteResult seg) => sum + seg.distance,
  );
  double get totalDuration => _routeSegments.fold(
    0,
    (double sum, RouteResult seg) => sum + seg.duration,
  );

  String get formattedTotalDistance =>
      (totalDistance / 1000).toStringAsFixed(2);
  String get formattedTotalDuration {
    final int minutes = (totalDuration / 60).floor();
    final int seconds = (totalDuration % 60).round();
    return '$minutes분 $seconds초';
  }

  String get formattedAvgSlope => '0%'; // 평균 경사도 계산 로직 필요시 추가

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
                  if (_routeSegments.isNotEmpty)
                    PolylineLayer<Object>(
                      polylines:
                          _routeSegments
                              .map(
                                (RouteResult segment) => Polyline<Object>(
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
                child: RouteCreationActions(
                  isButtonPressed: _isButtonPressed,
                  onToggleButton: _toggleButtonState,
                  onRemoveLastPin: _removeLastPin,
                  onMoveToCurrentLocation: _moveToCurrentLocation,
                  hasPins: _pins.isNotEmpty,
                ),
              ),
            ],
          ),
        ),
        RouteInfoBar(
          totalDistance: formattedTotalDistance,
          totalDuration: formattedTotalDuration,
          avgSlope: formattedAvgSlope,
        ),
      ],
    );
  }
}

class RouteInfoBar extends StatelessWidget {
  const RouteInfoBar({
    super.key,
    required this.totalDistance,
    required this.totalDuration,
    required this.avgSlope,
  });
  final String totalDistance;
  final String totalDuration;
  final String avgSlope;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _InfoItem(label: '예상 소요시간', value: totalDuration),
            _InfoItem(label: '총 거리', value: '$totalDistance km'),
            _InfoItem(label: '평균 경사도', value: avgSlope),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
