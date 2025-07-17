import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/place_search/domain/entities/place.dart';
import 'package:ridingmate/features/place_search/presentation/screens/place_search_screen.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/create_route_use_case.dart';
import 'package:ridingmate/features/route_planning/application/use_cases/route_planning_facade.dart';
import 'package:ridingmate/features/route_planning/di/route_providers.dart';
import 'package:ridingmate/features/route_planning/domain/entities/route_segment.dart';
import 'package:ridingmate/features/route_planning/presentation/screens/route_create_complete_screen.dart';
import 'package:ridingmate/features/route_planning/presentation/widgets/route_create_bottom_panel.dart';
import 'package:ridingmate/features/route_planning/presentation/widgets/route_creation_actions.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/floating_search_app_bar.dart';
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
  final List<RouteSegment> _routeSegments = <RouteSegment>[];
  bool _isRouteLoading = false;
  bool _isSaveMode = false;
  Place? _selectedPlace;
  final List<Place> _searchedPlaces = <Place>[];

  late final RoutePlanningFacade _facade;

  @override
  void initState() {
    super.initState();
    _facade = ref.read(routePlanningFacadeProvider);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
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

  void _onCloseTap() {
    setState(() {
      _selectedPlace = null;
      _searchedPlaces.clear();
    });
  }

  Future<void> _openSearchScreen() async {
    final dynamic result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => const PlaceSearchScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        if (result is Place) {
          // 단일 장소 선택
          _selectedPlace = result;
          _searchedPlaces.clear();
          _moveToPlace(result);
        } else if (result is List<Place>) {
          // 검색 결과 전체 선택
          _selectedPlace = null;
          _searchedPlaces.clear();
          _searchedPlaces.addAll(result);

          if (result.isNotEmpty) {
            // 첫 번째 장소로 지도 이동
            _moveToPlace(result.first);

            // 모든 검색 결과가 보이도록 지도 범위 조정
            _fitMapToSearchResults();
          }
        }
      });
    }
  }

  void _moveToPlace(Place place) {
    final LatLng position = LatLng(place.latitude, place.longitude);

    // 선택된 장소로 지도 이동
    _mapController.move(position, initialZoom);
  }

  Future<void> _getRoute() async {
    if (_pins.length < 2) return;

    setState(() {
      _isRouteLoading = true;
    });

    final RouteResult<RouteSegment> result = await _facade.createRoute.execute(
      _pins[_pins.length - 2],
      _pins[_pins.length - 1],
    );

    if (mounted) {
      setState(() {
        _isRouteLoading = false;
      });

      switch (result) {
        case final RouteSuccess<RouteSegment> success:
          setState(() {
            _routeSegments.add(success.data);
            _pins[_pins.length - 2] = success.data.points.first;
            _pins[_pins.length - 1] = success.data.points.last;
          });
        case final RouteFailure<RouteSegment> failure:
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
    final LatLngBounds bounds = _facade.fitMapToRoutes.execute(_routeSegments);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(20)),
    );
  }

  void _fitMapToSearchResults() {
    if (_searchedPlaces.isEmpty) return;

    if (_searchedPlaces.length == 1) {
      _moveToPlace(_searchedPlaces.first);
      return;
    }

    // 모든 검색 결과를 포함하는 범위 계산
    double minLat = _searchedPlaces.first.latitude;
    double maxLat = _searchedPlaces.first.latitude;
    double minLng = _searchedPlaces.first.longitude;
    double maxLng = _searchedPlaces.first.longitude;

    for (final Place place in _searchedPlaces) {
      if (place.latitude < minLat) minLat = place.latitude;
      if (place.latitude > maxLat) maxLat = place.latitude;
      if (place.longitude < minLng) minLng = place.longitude;
      if (place.longitude > maxLng) maxLng = place.longitude;
    }

    final LatLngBounds bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
    );
  }

  void _enterSaveMode() {
    _fitMapToAllRoutes();
    setState(() {
      _isSaveMode = true;
      _isButtonPressed = false;
    });
  }

  void _exitSaveMode() {
    setState(() {
      _isSaveMode = false;
    });
  }

  Future<void> _completeRouteSave(String title) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _facade.saveRoute.execute(_routeSegments, title);

      if (!mounted) return;

      Navigator.of(context).pop();
      _exitSaveMode();

      Navigator.push(
        context,
        PageRouteBuilder<void>(
          pageBuilder:
              (
                BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
              ) => RouteCreateCompleteScreen(
                routeTitle: title,
                totalDistance: formattedTotalDistance,
                totalDuration: formattedTotalDuration,
                elevationGain: formattedElevationGain,
              ),
          transitionDuration: Duration.zero,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('경로 저장에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  String get formattedTotalDistance =>
      _facade.routeStats.getFormattedTotalDistance(_routeSegments);
  String get formattedTotalDuration =>
      _facade.routeStats.getFormattedTotalDuration(_routeSegments);
  String get formattedElevationGain =>
      _facade.routeStats.getFormattedElevationGain(_routeSegments);

  String _getSearchText() {
    if (_selectedPlace != null) {
      return _selectedPlace!.title;
    } else if (_searchedPlaces.isNotEmpty) {
      return '${_searchedPlaces.length}개 장소 검색됨';
    } else {
      return '장소, 위치 검색하기';
    }
  }

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

  void _onMarkerTap() {
    // TODO: 장소 마커 탭 시 동작 추가
  }

  void _onSearchResultMarkerTap(Place place) {
    // 검색 결과 마커를 탭했을 때 해당 장소로 지도 이동
    _moveToPlace(place);
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
                  onTap: (_, LatLng position) => _addPin(position),
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
                  PolylineLayer<LatLng>(
                    polylines:
                        _routeSegments
                            .map(
                              (RouteSegment segment) => Polyline<LatLng>(
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
                  // 검색된 장소 마커
                  if (_selectedPlace != null || _searchedPlaces.isNotEmpty)
                    MarkerLayer(
                      markers: <Marker>[
                        // 단일 선택된 장소 마커
                        if (_selectedPlace != null)
                          Marker(
                            point: LatLng(
                              _selectedPlace!.latitude,
                              _selectedPlace!.longitude,
                            ),
                            width: 34,
                            height: 34,
                            child: GestureDetector(
                              onTap: _onMarkerTap,
                              child: Icon(
                                Icons.place,
                                color: context.semanticColor.primaryNormal,
                                size: 40,
                              ),
                            ),
                          ),
                        // 검색 결과 전체 장소 마커들
                        ..._searchedPlaces.map(
                          (Place place) => Marker(
                            point: LatLng(place.latitude, place.longitude),
                            width: 34,
                            height: 34,
                            child: GestureDetector(
                              onTap: () => _onSearchResultMarkerTap(place),
                              child: Icon(
                                Icons.location_on,
                                color: context.semanticColor.primaryNormal,
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (_isRouteLoading)
                const Positioned.fill(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_isSaveMode)
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: FloatingSearchAppBar(
                    searchText: _getSearchText(),
                    onSearchTap: _openSearchScreen,
                    onCloseTap: _onCloseTap,
                    isSearchActive:
                        _selectedPlace != null || _searchedPlaces.isNotEmpty,
                  ),
                ),
              if (!_isSaveMode)
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
