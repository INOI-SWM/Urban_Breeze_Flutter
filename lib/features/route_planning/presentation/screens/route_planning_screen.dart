import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/place_search/domain/entities/place.dart';
import 'package:urban_breeze/features/place_search/domain/entities/search_result.dart';
import 'package:urban_breeze/features/place_search/presentation/screens/place_search_screen.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/route_planning_facade.dart';
import 'package:urban_breeze/features/route_planning/di/route_providers.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/planned_route.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_pin.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_segment.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/waypoint.dart';
import 'package:urban_breeze/features/route_planning/presentation/screens/route_create_complete_screen.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/route_create_bottom_panel.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/route_creation_actions.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/waypoint_setting_modal.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/floating_search_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/design_system/widgets/marker/route_pin_marker.dart';
import 'package:urban_breeze/shared/map/common_map_widgets.dart';
import 'package:urban_breeze/shared/map/map_constants.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class RoutePlanningScreen extends ConsumerStatefulWidget {
  const RoutePlanningScreen({super.key});

  @override
  ConsumerState<RoutePlanningScreen> createState() =>
      _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends ConsumerState<RoutePlanningScreen>
    with ErrorDisplayMixin {
  static const LatLng _seoulCityHall = MapConstants.seoulCityHall;
  static const double _defaultZoom = MapConstants.routePlanningZoom;

  final LatLng initialCenter = _seoulCityHall;
  final double initialZoom = _defaultZoom;

  LatLng? _currentPosition;
  bool _isLocationLoading = true;

  final MapController _mapController = MapController();

  bool _isButtonPressed = false;
  PlannedRoute _route = const PlannedRoute(
    pins: <RoutePin>[],
    segments: <RouteSegment>[],
  ); // 경로 전체 관리
  bool _isRouteLoading = false;
  bool _isSaveMode = false;
  Place? _selectedPlace;
  final List<Place> _searchedPlaces = <Place>[];
  String? _lastSearchQuery;

  late final RoutePlanningFacade _facade;

  @override
  void initState() {
    super.initState();
    _facade = ref.read(routePlanningFacadeProvider);
    _getCurrentLocation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AmplitudeAnalytics.logScreenView('route_planning_screen');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final LatLng? position = await _facade.getCurrentLocation.execute();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentPosition = null;
          _isLocationLoading = false;
        });
      }
    }
  }

  void _moveToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, initialZoom);
    } else {
      showErrorMessage(context, '휴대폰 설정에서 위치권한을 설정해주세요');
    }
  }

  void _toggleButtonState() {
    setState(() {
      _isButtonPressed = !_isButtonPressed;
    });

    AmplitudeAnalytics.logEvent(
      'route_planning_pin_mode_toggled',
      properties: <String, dynamic>{'is_pin_mode_active': _isButtonPressed},
    );
  }

  void _onCloseTap() {
    AmplitudeAnalytics.logButtonClick('route_planning_close');
    Navigator.of(context).pop();
  }

  void _onClearTap() {
    AmplitudeAnalytics.logButtonClick('route_planning_clear_search');
    setState(() {
      _selectedPlace = null;
      _searchedPlaces.clear();
      _lastSearchQuery = null;
    });
  }

  Future<void> _openSearchScreen() async {
    AmplitudeAnalytics.logButtonClick('route_planning_search');

    final dynamic result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder:
            (BuildContext context) =>
                PlaceSearchScreen(initialLocation: _currentPosition),
      ),
    );

    if (result == null) return;

    _handleSearchResult(result);
  }

  void _handleSearchResult(dynamic result) {
    setState(() {
      if (result is Place) {
        _handleSinglePlaceSelection(result);
      } else if (result is SearchResult) {
        _handleMultiplePlacesSelection(result);
      }
    });
  }

  void _handleSinglePlaceSelection(Place place) {
    _selectedPlace = place;
    _searchedPlaces.clear();
    _lastSearchQuery = null;
    _moveToPlace(place);

    // 단일 장소 선택 이벤트
    AmplitudeAnalytics.logEvent(
      'route_planning_place_selected',
      properties: <String, dynamic>{
        'place_title': place.title,
        'place_address': place.address,
        'selection_type': 'single',
      },
    );
  }

  void _handleMultiplePlacesSelection(SearchResult searchResult) {
    _selectedPlace = null;
    _searchedPlaces.clear();
    _lastSearchQuery = searchResult.query;
    _searchedPlaces.addAll(searchResult.places);

    if (searchResult.places.isNotEmpty) {
      _moveToPlace(searchResult.places.first);
      _fitMapToSearchResults(searchResult);
    }

    // 다중 장소 선택 이벤트
    AmplitudeAnalytics.logEvent(
      'route_planning_places_selected',
      properties: <String, dynamic>{
        'search_query': searchResult.query,
        'places_count': searchResult.places.length,
        'selection_type': 'multiple',
      },
    );
  }

  void _moveToPlace(Place place) {
    final LatLng position = LatLng(place.latitude, place.longitude);

    // 선택된 장소로 지도 이동
    _mapController.move(position, initialZoom);
  }

  Future<void> _getRoute() async {
    if (_route.pins.length < 2) return;

    setState(() {
      _isRouteLoading = true;
    });

    final AppResult<RouteSegment> result = await _facade.createRoute.execute(
      _route.pins[_route.pins.length - 2].position,
      _route.pins[_route.pins.length - 1].position,
    );

    if (mounted) {
      setState(() {
        _isRouteLoading = false;
      });

      switch (result) {
        case final AppSuccess<RouteSegment> success:
          setState(() {
            // addSegment가 자동으로 핀 위치도 업데이트
            _route = _route.addSegment(success.data);
          });
          AmplitudeAnalytics.logEvent(
            'route_planning_route_created',
            properties: <String, dynamic>{
              'route_segments_count': _route.segments.length,
              'total_pins': _route.pins.length,
            },
          );
        case final AppFailure<RouteSegment> failure:
          _removeLastPin(shouldRemoveRouteSegment: false);
          AmplitudeAnalytics.logEvent(
            'route_planning_route_failed',
            properties: <String, dynamic>{
              'error_type': failure.exceptionOrNull?.runtimeType.toString(),
            },
          );

          showErrorFromAppResult(context, failure);
      }
    }
  }

  void _addPin(LatLng position) {
    if (_isRouteLoading) return;

    // managePins UseCase는 여전히 LatLng 리스트를 받으므로 변환 필요
    final List<LatLng> pinPositions =
        _route.pins.map((RoutePin pin) => pin.position).toList();

    if (_facade.managePins.shouldAddPin(_isButtonPressed, pinPositions)) {
      setState(() {
        _route = _route.addPin(RoutePin(position: position));
      });
      AmplitudeAnalytics.logEvent(
        'route_planning_pin_added',
        properties: <String, dynamic>{
          'pin_count': _route.pins.length,
          'pin_latitude': position.latitude,
          'pin_longitude': position.longitude,
        },
      );

      final List<LatLng> updatedPinPositions =
          _route.pins.map((RoutePin pin) => pin.position).toList();
      if (_facade.managePins.shouldGetRoute(updatedPinPositions)) {
        _getRoute();
      }
    }
  }

  void _removeLastPin({bool shouldRemoveRouteSegment = true}) {
    setState(() {
      _route = _route.removeLastPin(removeSegment: shouldRemoveRouteSegment);
    });

    AmplitudeAnalytics.logEvent(
      'route_planning_pin_removed',
      properties: <String, dynamic>{
        'remaining_pins': _route.pins.length,
        'remaining_segments': _route.segments.length,
      },
    );
  }

  void _fitMapToAllRoutes() {
    final LatLngBounds bounds = _facade.fitMapToRoutes.execute(_route.segments);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(20)),
    );
  }

  void _fitMapToSearchResults(SearchResult searchResult) {
    if (searchResult.places.isEmpty) return;

    // 서버에서 받은 bbox 정보를 우선 사용
    if (searchResult.bbox != null) {
      final LatLngBounds bounds = LatLngBounds(
        LatLng(searchResult.bbox!.minLat, searchResult.bbox!.minLon),
        LatLng(searchResult.bbox!.maxLat, searchResult.bbox!.maxLon),
      );
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
      return;
    }

    // bbox 정보가 없는 경우 클라이언트에서 계산
    if (searchResult.places.length == 1) {
      _moveToPlace(searchResult.places.first);
      return;
    }

    // 모든 검색 결과를 포함하는 범위 계산
    double minLat = searchResult.places.first.latitude;
    double maxLat = searchResult.places.first.latitude;
    double minLng = searchResult.places.first.longitude;
    double maxLng = searchResult.places.first.longitude;

    for (final Place place in searchResult.places) {
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

    AmplitudeAnalytics.logEvent(
      'route_planning_save_mode_entered',
      properties: <String, dynamic>{
        'total_distance': formattedTotalDistance,
        'total_duration': formattedTotalDuration,
        'elevation_gain': formattedElevationGain,
        'route_segments_count': _route.segments.length,
      },
    );
  }

  void _exitSaveMode() {
    setState(() {
      _isSaveMode = false;
    });

    AmplitudeAnalytics.logEvent('route_planning_save_mode_exited');
  }

  Future<void> _completeRouteSave(String title) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: AppLoadingIndicator()),
    );

    try {
      await _facade.saveRoute.execute(_route.withTitle(title));

      if (!mounted) return;

      Navigator.of(context).pop();
      _exitSaveMode();

      AmplitudeAnalytics.logEvent(
        'route_planning_route_saved',
        properties: <String, dynamic>{
          'route_title': title,
          'total_distance': formattedTotalDistance,
          'total_duration': formattedTotalDuration,
          'elevation_gain': formattedElevationGain,
          'route_segments_count': _route.segments.length,
        },
      );

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
      AmplitudeAnalytics.logEvent(
        'route_planning_route_save_failed',
        properties: <String, dynamic>{'error_message': e.toString()},
      );

      showErrorMessage(context, '경로 저장에 실패했습니다. 다시 시도해주세요.');
    }
  }

  String get formattedTotalDistance =>
      _facade.routeStats.getFormattedTotalDistance(_route.segments);
  String get formattedTotalDuration =>
      _facade.routeStats.getFormattedTotalDuration(_route.segments);
  String get formattedElevationGain =>
      _facade.routeStats.getFormattedElevationGain(_route.segments);

  String _getSearchText() {
    if (_selectedPlace != null) {
      return _selectedPlace!.title;
    } else if (_searchedPlaces.isNotEmpty && _lastSearchQuery != null) {
      return _lastSearchQuery!;
    } else {
      return '';
    }
  }

  Widget _buildBottomBar() {
    return IgnorePointer(
      ignoring: _isRouteLoading,
      child: Opacity(
        opacity: _isRouteLoading ? 0.5 : 1.0,
        child: RouteCreateBottomPanel(
          mode: _isSaveMode ? RouteCreateMode.save : RouteCreateMode.create,
          totalDistance: formattedTotalDistance,
          totalDuration: formattedTotalDuration,
          elevationGain: formattedElevationGain,
          hasRoute: _route.segments.isNotEmpty,
          onSave: _enterSaveMode,
          onBack: _exitSaveMode,
          onComplete: _completeRouteSave,
        ),
      ),
    );
  }

  void _onMarkerTap() {
    // TODO: 장소 마커 탭 시 동작 추가
  }

  void _onPinTap(int pinIndex) {
    final RoutePin pin = _route.pins[pinIndex];

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext context) => WaypointSettingModal(
            position: pin.position,
            initialWaypoint: pin.waypoint,
            onSave: (Waypoint waypoint) {
              setState(() {
                _route = _route.updatePinWaypoint(
                  pinIndex,
                  pin.copyWithWaypoint(waypoint),
                );
              });

              AmplitudeAnalytics.logEvent(
                'route_planning_waypoint_set',
                properties: <String, dynamic>{
                  'pin_index': pinIndex,
                  'waypoint_type': waypoint.type.name,
                  'waypoint_title': waypoint.title,
                },
              );
            },
            onDelete: () {
              // waypoint 삭제 (기본 핀으로 되돌리기)
              setState(() {
                _route = _route.updatePinWaypoint(
                  pinIndex,
                  RoutePin(position: pin.position), // waypoint 없는 기본 핀
                );
              });

              AmplitudeAnalytics.logEvent(
                'route_planning_waypoint_deleted',
                properties: <String, dynamic>{'pin_index': pinIndex},
              );
            },
          ),
    );
  }

  void _onSearchResultMarkerTap(Place place) {
    // 검색 결과 마커를 탭했을 때 해당 장소로 지도 이동
    _moveToPlace(place);
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    if (_isLocationLoading) {
      return const Center(child: AppLoadingIndicator());
    }

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      resizeToAvoidBottomInset: _isSaveMode, // 저장 모드에서만 키보드 리사이즈 허용
      body: SafeArea(
        child: Column(
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
                      CommonMapWidgets.createTileLayer(),
                      CommonMapWidgets.createAttributionWidget(),
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
                            _route.segments
                                .map(
                                  (RouteSegment segment) => Polyline<LatLng>(
                                    points: segment.points,
                                    color: colors.primaryNormal,
                                    strokeWidth:
                                        MapConstants.polylineStrokeWidth,
                                  ),
                                )
                                .toList(),
                      ),
                      MarkerLayer(
                        markers:
                            _route.pins.asMap().entries.map((
                              MapEntry<int, RoutePin> entry,
                            ) {
                              final int index = entry.key;
                              final RoutePin pin = entry.value;
                              final RoutePinMarker pinMarker = RoutePinMarker(
                                index: index,
                                hasWaypoint: pin.hasWaypoint,
                                waypoint: pin.waypoint,
                              );

                              return Marker(
                                point: pin.position,
                                width: pinMarker.flutterMapMarkerSize,
                                height: pinMarker.flutterMapMarkerSize,
                                child: GestureDetector(
                                  onTap: () => _onPinTap(index),
                                  child: pinMarker,
                                ),
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
                                    color: colors.primaryNormal,
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
                                    color: colors.primaryNormal,
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
                      child: Center(child: AppLoadingIndicator()),
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
                        onClearTap: _onClearTap,
                        isSearchActive:
                            _selectedPlace != null ||
                            _searchedPlaces.isNotEmpty,
                      ),
                    ),
                  if (!_isSaveMode)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: IgnorePointer(
                        ignoring: _isRouteLoading,
                        child: Opacity(
                          opacity: _isRouteLoading ? 0.5 : 1.0,
                          child: RouteCreationActionButtons(
                            isPinButtonPressed: _isButtonPressed,
                            onTogglePinButton: _toggleButtonState,
                            onRemoveLastPin: _removeLastPin,
                            onMoveToCurrentLocation: _moveToCurrentLocation,
                            hasPins: _route.pins.isNotEmpty,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }
}
