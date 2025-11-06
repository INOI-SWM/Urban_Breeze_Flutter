import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/core/theme/app_theme.dart';
import 'package:urban_breeze/features/place_search/domain/entities/place.dart';
import 'package:urban_breeze/features/place_search/domain/entities/search_result.dart';
import 'package:urban_breeze/features/place_search/presentation/screens/place_search_screen.dart';
import 'package:urban_breeze/features/route_planning/application/use_cases/route_planning_facade.dart';
import 'package:urban_breeze/features/route_planning/di/route_providers.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/planned_route.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_pin.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_segment.dart'
    as route_planning;
import 'package:urban_breeze/features/route_planning/domain/entities/waypoint.dart';
import 'package:urban_breeze/features/route_planning/presentation/screens/route_create_complete_screen.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/route_create_bottom_panel.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/route_creation_actions.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/waypoint_setting_modal.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/floating_search_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:urban_breeze/shared/design_system/widgets/marker/route_pin_marker.dart';
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
  static const latlong2.LatLng _seoulCityHall = MapConstants.seoulCityHall;
  static const double _defaultZoom = MapConstants.routePlanningZoom;

  final latlong2.LatLng initialCenter = _seoulCityHall;
  final double initialZoom = _defaultZoom;

  latlong2.LatLng? _currentPosition;
  bool _isLocationLoading = true;

  kakao.KakaoMapController? _mapController;

  bool _isButtonPressed = false;
  DateTime? _lastButtonToggleTime;
  bool _isRoutePinPoiClicked = false;
  PlannedRoute _route = PlannedRoute(
    pins: <RoutePin>[],
    segments: <route_planning.RouteSegment>[],
  );
  bool _isRouteLoading = false;
  bool _isSaveMode = false;
  Place? _selectedPlace;
  final List<Place> _searchedPlaces = <Place>[];
  String? _lastSearchQuery;

  final List<kakao.Poi> _currentLocationPois = <kakao.Poi>[];
  final List<kakao.Poi> _routePinPois = <kakao.Poi>[];
  final List<kakao.Poi> _searchPlacePois = <kakao.Poi>[];
  final List<kakao.Route> _routeRoutes = <kakao.Route>[];

  final Map<String, int> _poiIdToPinIndex = <String, int>{};

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
      final latlong2.LatLng? position =
          await _facade.getCurrentLocation.execute();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLocationLoading = false;
        });
        _updateCurrentLocationMarker();
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

  Future<void> _moveToCurrentLocation() async {
    if (_currentPosition != null && _mapController != null) {
      final kakao.CameraUpdate cameraUpdate = kakao
          .CameraUpdate.newCenterPosition(
        kakao.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      );
      await _mapController!.moveCamera(cameraUpdate);
    } else {
      showErrorMessage(context, '휴대폰 설정에서 위치권한을 설정해주세요');
    }
  }

  void _toggleButtonState() {
    _lastButtonToggleTime = DateTime.now();

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
    _updateSearchPlaceMarkers();
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
    if (result is Place) {
      _handleSinglePlaceSelection(result);
    } else if (result is SearchResult) {
      _handleMultiplePlacesSelection(result);
    }
  }

  void _handleSinglePlaceSelection(Place place) {
    setState(() {
      _selectedPlace = place;
      _searchedPlaces.clear();
      _lastSearchQuery = null;
    });
    _moveToPlace(place);
    _updateSearchPlaceMarkers();

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
    setState(() {
      _selectedPlace = null;
      _searchedPlaces.clear();
      _lastSearchQuery = searchResult.query;
      _searchedPlaces.addAll(searchResult.places);
    });

    if (searchResult.places.isNotEmpty) {
      _fitMapToSearchResults(searchResult);
    }
    _updateSearchPlaceMarkers();

    AmplitudeAnalytics.logEvent(
      'route_planning_places_selected',
      properties: <String, dynamic>{
        'search_query': searchResult.query,
        'places_count': searchResult.places.length,
        'selection_type': 'multiple',
      },
    );
  }

  Future<void> _moveToPlace(Place place) async {
    if (_mapController != null) {
      final kakao.CameraPosition cameraPosition = kakao.CameraPosition(
        kakao.LatLng(place.latitude, place.longitude),
        initialZoom.toInt(),
        rotationAngle: 0.0,
      );
      final kakao.CameraUpdate cameraUpdate = kakao.CameraUpdate.newCameraPos(
        cameraPosition,
      );
      await _mapController!.moveCamera(cameraUpdate);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final kakao.CameraUpdate rotateUpdate = kakao.CameraUpdate.rotate(0.0);
      await _mapController!.moveCamera(rotateUpdate);
    }
  }

  Future<void> _getRoute() async {
    if (_route.pins.length < 2) return;

    setState(() {
      _isRouteLoading = true;
    });

    // 인덱스 접근을 변수로 저장하여 중복 계산 방지
    final int pinsLength = _route.pins.length;
    final latlong2.LatLng startPosition = _route.pins[pinsLength - 2].position;
    final latlong2.LatLng endPosition = _route.pins[pinsLength - 1].position;

    final AppResult<route_planning.RouteSegment> result = await _facade
        .createRoute
        .execute(startPosition, endPosition);

    if (mounted) {
      setState(() {
        _isRouteLoading = false;
      });

      switch (result) {
        case final AppSuccess<route_planning.RouteSegment> success:
          setState(() {
            _route = _route.addSegment(success.data);
          });
          _updateRoutePins();
          _updateRouteLines();
          AmplitudeAnalytics.logEvent(
            'route_planning_route_created',
            properties: <String, dynamic>{
              'route_segments_count': _route.segments.length,
              'total_pins': _route.pins.length,
            },
          );
        case final AppFailure<route_planning.RouteSegment> failure:
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

  void _addPin(latlong2.LatLng position) {
    if (_isRouteLoading) {
      return;
    }

    // shouldAddPin은 pins.length만 확인하므로 리스트 생성 불필요
    final int currentPinCount = _route.pins.length;
    final bool canAddPin = _facade.managePins.shouldAddPin(
      _isButtonPressed,
      _route.pins.map((RoutePin pin) => pin.position).toList(),
    );

    if (canAddPin) {
      setState(() {
        _route = _route.addPin(RoutePin(position: position));
      });
      _updateRoutePins();
      AmplitudeAnalytics.logEvent(
        'route_planning_pin_added',
        properties: <String, dynamic>{
          'pin_count': _route.pins.length,
          'pin_latitude': position.latitude,
          'pin_longitude': position.longitude,
        },
      );

      // shouldGetRoute는 단순히 pins.length >= 2를 확인
      if (currentPinCount + 1 >= 2) {
        _getRoute();
      }
    }
  }

  Future<void> _removeLastPin({bool shouldRemoveRouteSegment = true}) async {
    setState(() {
      _route = _route.removeLastPin(removeSegment: shouldRemoveRouteSegment);
    });

    _updateRoutePins();
    _updateRouteLines();

    AmplitudeAnalytics.logEvent(
      'route_planning_pin_removed',
      properties: <String, dynamic>{
        'remaining_pins': _route.pins.length,
        'remaining_segments': _route.segments.length,
      },
    );
  }

  Future<void> _fitMapToAllRoutes() async {
    if (_mapController == null || _route.segments.isEmpty) return;

    // fitMapPoints를 사용하여 더 효율적으로 처리
    final List<kakao.LatLng> fitPoints = <kakao.LatLng>[];
    for (final route_planning.RouteSegment segment in _route.segments) {
      if (segment.points.isNotEmpty) {
        fitPoints.addAll(
          segment.points.map(
            (latlong2.LatLng point) =>
                kakao.LatLng(point.latitude, point.longitude),
          ),
        );
      }
    }

    if (fitPoints.isNotEmpty) {
      final kakao.CameraUpdate cameraUpdate = kakao.CameraUpdate.fitMapPoints(
        fitPoints,
        padding: 20,
      );
      await _mapController!.moveCamera(cameraUpdate);
    }
  }

  Future<void> _fitMapToSearchResults(SearchResult searchResult) async {
    if (searchResult.places.isEmpty || _mapController == null) return;

    if (searchResult.places.length == 1) {
      _moveToPlace(searchResult.places.first);
      return;
    }

    final List<kakao.LatLng> fitPoints =
        searchResult.places
            .map((Place place) => kakao.LatLng(place.latitude, place.longitude))
            .toList();

    if (fitPoints.isNotEmpty) {
      final kakao.CameraUpdate cameraUpdate = kakao.CameraUpdate.fitMapPoints(
        fitPoints,
        padding: 20,
      );
      await _mapController!.moveCamera(cameraUpdate);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final kakao.CameraUpdate rotateUpdate = kakao.CameraUpdate.rotate(0.0);
      await _mapController!.moveCamera(rotateUpdate);
    }
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

  void _showWaypointSettingModal(int pinIndex) {
    if (pinIndex < 0 || pinIndex >= _route.pins.length) return;

    final RoutePin pin = _route.pins[pinIndex];

    AmplitudeAnalytics.logEvent(
      'route_planning_waypoint_modal_opened',
      properties: <String, dynamic>{
        'pin_index': pinIndex,
        'has_waypoint': pin.hasWaypoint,
      },
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext context) => WaypointSettingModal(
            position: pin.position,
            initialWaypoint: pin.waypoint,
            onSave: (Waypoint waypoint) {
              _updatePinWaypoint(pinIndex, waypoint);
            },
            onDelete:
                pin.hasWaypoint
                    ? () {
                      _updatePinWaypoint(pinIndex, null);
                    }
                    : null,
          ),
    );
  }

  void _updatePinWaypoint(int pinIndex, Waypoint? waypoint) {
    if (pinIndex < 0 || pinIndex >= _route.pins.length) return;

    final RoutePin pin = _route.pins[pinIndex];
    final RoutePin updatedPin = pin.copyWithWaypoint(waypoint);

    setState(() {
      _route = _route.updatePinWaypoint(pinIndex, updatedPin);
    });

    _updateRoutePins();

    AmplitudeAnalytics.logEvent(
      'route_planning_waypoint_updated',
      properties: <String, dynamic>{
        'pin_index': pinIndex,
        'has_waypoint': waypoint != null,
        if (waypoint != null) 'waypoint_type': waypoint.type.name,
      },
    );
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

  Future<void> _updateCurrentLocationMarker() async {
    if (_mapController == null || !mounted) return;

    try {
      for (final kakao.Poi poi in _currentLocationPois) {
        try {
          await _mapController!.labelLayer.removePoi(poi);
        } catch (e) {
          debugPrint('현위치 POI 제거 실패: $e');
        }
      }
      _currentLocationPois.clear();

      if (_currentPosition != null && mounted && _mapController != null) {
        try {
          final kakao.KImage iconImage = kakao.KImage.fromAsset(
            'assets/icons/png/current_location_pin.png',
            24,
            24,
          );
          final kakao.Poi poi = await _mapController!.labelLayer.addPoi(
            kakao.LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            style: kakao.PoiStyle(icon: iconImage),
          );
          if (mounted) {
            _currentLocationPois.add(poi);
          }
        } catch (e) {
          debugPrint('현위치 마커 추가 실패: $e');
        }
      }
    } catch (e) {
      debugPrint('현위치 마커 업데이트 실패: $e');
    }
  }

  Future<void> _updateRoutePins() async {
    if (_mapController == null || !mounted) return;

    try {
      for (final kakao.Poi poi in _routePinPois) {
        try {
          await _mapController!.labelLayer.removePoi(poi);
        } catch (e) {
          debugPrint('경로 핀 POI 제거 실패: $e');
        }
      }
      _routePinPois.clear();
      _poiIdToPinIndex.clear();

      if (!mounted || _mapController == null) return;

      final SemanticColors colors = context.semanticColor;

      final List<Future<void>> pinFutures = <Future<void>>[];
      for (int i = 0; i < _route.pins.length; i++) {
        if (!mounted || _mapController == null) break;

        final int pinIndex = i;
        final RoutePin pin = _route.pins[pinIndex];
        final RoutePinMarker marker = RoutePinMarker(
          index: pinIndex,
          hasWaypoint: pin.hasWaypoint,
          waypoint: pin.waypoint,
        );

        pinFutures.add(
          kakao.KImage.fromWidget(
                SemanticTheme(data: colors, child: marker),
                const Size(24, 24),
              )
              .then((kakao.KImage iconImage) async {
                if (!mounted || _mapController == null) return;

                final kakao.Poi poi = await _mapController!.labelLayer.addPoi(
                  kakao.LatLng(pin.position.latitude, pin.position.longitude),
                  style: kakao.PoiStyle(icon: iconImage),
                );
                if (mounted) {
                  _routePinPois.add(poi);
                  _poiIdToPinIndex[poi.id] = pinIndex;
                }
              })
              .catchError((Object e) {
                debugPrint('경로 핀 추가 실패 (인덱스 $pinIndex): $e');
              }),
        );
      }

      await Future.wait(pinFutures);
    } catch (e) {
      debugPrint('경로 핀 업데이트 실패: $e');
    }
  }

  Future<void> _updateRouteLines() async {
    if (_mapController == null || !mounted) return;

    try {
      for (final kakao.Route route in _routeRoutes) {
        try {
          await _mapController!.routeLayer.removeRoute(route);
        } catch (e) {
          // Route 제거 실패 시 무시
        }
      }

      _routeRoutes.clear();

      if (!mounted || _mapController == null) return;

      final SemanticColors colors = context.semanticColor;

      for (int i = 0; i < _route.segments.length; i++) {
        if (!mounted || _mapController == null) return;

        final route_planning.RouteSegment segment = _route.segments[i];

        if (segment.points.isEmpty) {
          continue;
        }

        final List<kakao.LatLng> points =
            segment.points
                .map(
                  (latlong2.LatLng point) =>
                      kakao.LatLng(point.latitude, point.longitude),
                )
                .toList();

        try {
          final kakao.RouteStyle routeStyle = kakao.RouteStyle(
            Color(colors.primaryNormal.toARGB32()),
            6.0, // 폴리라인 두께를 4.0에서 6.0으로 증가
          );

          final kakao.Route route = await _mapController!.routeLayer.addRoute(
            points,
            routeStyle,
          );

          if (mounted) {
            _routeRoutes.add(route);
          }
        } catch (e) {
          // 경로 라인 추가 실패 시 무시
        }
      }
    } catch (e) {
      // 경로 라인 업데이트 실패 시 무시
    }
  }

  Future<void> _updateSearchPlaceMarkers() async {
    if (_mapController == null || !mounted) return;

    try {
      // 기존 POI 제거를 병렬로 처리
      final List<Future<void>> removeFutures =
          _searchPlacePois.map((kakao.Poi poi) async {
            try {
              await _mapController!.labelLayer.removePoi(poi);
            } catch (e) {
              debugPrint('검색 장소 POI 제거 실패: $e');
            }
          }).toList();
      await Future.wait(removeFutures);
      _searchPlacePois.clear();

      if (!mounted || _mapController == null) return;

      final SemanticColors colors = context.semanticColor;

      final List<Future<void>> addFutures = <Future<void>>[];

      if (_selectedPlace != null) {
        final Place selectedPlace = _selectedPlace!;
        addFutures.add(
          kakao.KImage.fromWidget(
                Icon(Icons.place, color: colors.primaryNormal, size: 36),
                const Size(36, 36),
              )
              .then((kakao.KImage placeIcon) async {
                if (!mounted || _mapController == null) return;
                final kakao.Poi poi = await _mapController!.labelLayer.addPoi(
                  kakao.LatLng(selectedPlace.latitude, selectedPlace.longitude),
                  style: kakao.PoiStyle(icon: placeIcon),
                );
                if (mounted) {
                  _searchPlacePois.add(poi);
                }
              })
              .catchError((Object e) {
                debugPrint('선택된 장소 마커 추가 실패: $e');
              }),
        );
      }

      for (int i = 0; i < _searchedPlaces.length; i++) {
        if (!mounted || _mapController == null) break;

        final Place place = _searchedPlaces[i];
        final int placeIndex = i;
        addFutures.add(
          kakao.KImage.fromWidget(
                Icon(Icons.location_on, color: colors.primaryNormal, size: 34),
                const Size(34, 34),
              )
              .then((kakao.KImage locationIcon) async {
                if (!mounted || _mapController == null) return;
                final kakao.Poi poi = await _mapController!.labelLayer.addPoi(
                  kakao.LatLng(place.latitude, place.longitude),
                  style: kakao.PoiStyle(icon: locationIcon),
                );
                if (mounted) {
                  _searchPlacePois.add(poi);
                }
              })
              .catchError((Object e) {
                debugPrint('검색 결과 마커 추가 실패 (인덱스 $placeIndex): $e');
              }),
        );
      }

      await Future.wait(addFutures);
    } catch (e) {
      debugPrint('검색 장소 마커 업데이트 실패: $e');
    }
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
                  kakao.KakaoMap(
                    option: kakao.KakaoMapOption(
                      position:
                          _currentPosition != null
                              ? kakao.LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              )
                              : kakao.LatLng(
                                initialCenter.latitude,
                                initialCenter.longitude,
                              ),
                      zoomLevel: initialZoom.toInt(),
                      mapType: kakao.MapType.normal,
                    ),
                    onMapReady: (kakao.KakaoMapController controller) async {
                      _mapController = controller;
                      try {
                        await _updateCurrentLocationMarker();
                        await Future<void>.delayed(
                          const Duration(milliseconds: 50),
                        );
                        await _updateRoutePins();
                        await Future<void>.delayed(
                          const Duration(milliseconds: 50),
                        );
                        await _updateRouteLines();
                        await Future<void>.delayed(
                          const Duration(milliseconds: 50),
                        );
                        await _updateSearchPlaceMarkers();
                      } catch (e) {
                        debugPrint('지도 준비 후 마커 업데이트 실패: $e');
                      }
                    },
                    onPoiClick: (
                      kakao.LabelController labelController,
                      kakao.Poi poi,
                    ) {
                      if (_poiIdToPinIndex.containsKey(poi.id)) {
                        _isRoutePinPoiClicked = true;

                        Future<void>.delayed(
                          const Duration(milliseconds: 200),
                          () {
                            if (mounted) {
                              _isRoutePinPoiClicked = false;
                            }
                          },
                        );

                        final int pinIndex = _poiIdToPinIndex[poi.id]!;
                        if (pinIndex < _route.pins.length) {
                          _showWaypointSettingModal(pinIndex);
                        }
                      }
                    },
                    onMapClick: (kakao.KPoint point, kakao.LatLng latLng) {
                      Future<void>.delayed(
                        const Duration(milliseconds: 100),
                        () {
                          if (!mounted) return;

                          if (_isButtonPressed && !_isRouteLoading) {
                            if (_isRoutePinPoiClicked) {
                              _isRoutePinPoiClicked = false;
                              return;
                            }

                            if (_lastButtonToggleTime != null) {
                              final DateTime now = DateTime.now();
                              final Duration timeSinceToggle = now.difference(
                                _lastButtonToggleTime!,
                              );
                              if (timeSinceToggle.inMilliseconds < 500) {
                                return;
                              }
                            }

                            _addPin(
                              latlong2.LatLng(
                                latLng.latitude,
                                latLng.longitude,
                              ),
                            );
                          }
                        },
                      );
                    },
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
                      child: AbsorbPointer(
                        absorbing: _isRouteLoading,
                        child: Opacity(
                          opacity: _isRouteLoading ? 0.5 : 1.0,
                          child: RouteCreationActionButtons(
                            isPinButtonPressed: _isButtonPressed,
                            onTogglePinButton: () {
                              _lastButtonToggleTime = DateTime.now();
                              _toggleButtonState();
                            },
                            onRemoveLastPin: () {
                              _lastButtonToggleTime = DateTime.now();
                              _removeLastPin();
                            },
                            onMoveToCurrentLocation: () {
                              _lastButtonToggleTime = DateTime.now();
                              _moveToCurrentLocation();
                            },
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
