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
import 'package:urban_breeze/features/route_planning/presentation/screens/route_create_complete_screen.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/route_create_bottom_panel.dart';
import 'package:urban_breeze/features/route_planning/presentation/widgets/route_creation_actions.dart';
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
  DateTime? _lastButtonToggleTime; // 버튼 토글 시간 추적
  PlannedRoute _route = PlannedRoute(
    pins: <RoutePin>[],
    segments: <route_planning.RouteSegment>[],
  ); // 경로 전체 관리
  bool _isRouteLoading = false;
  bool _isSaveMode = false;
  Place? _selectedPlace;
  final List<Place> _searchedPlaces = <Place>[];
  String? _lastSearchQuery;

  // kakao_map_sdk 오버레이 관리 (Poi와 Route로 관리)
  final List<kakao.Poi> _currentLocationPois = <kakao.Poi>[];
  final List<kakao.Poi> _routePinPois = <kakao.Poi>[];
  final List<kakao.Poi> _searchPlacePois = <kakao.Poi>[];
  final List<kakao.Route> _routeRoutes = <kakao.Route>[];

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
    // 모드 전환 시 자동 핀 추가를 방지하기 위해 시간 기록
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
    _updateSearchPlaceMarkers();

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
      _fitMapToSearchResults(searchResult);
    }
    _updateSearchPlaceMarkers();

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

  Future<void> _moveToPlace(Place place) async {
    if (_mapController != null) {
      // CameraPosition을 사용하여 위치와 zoom level을 명시적으로 설정
      final kakao.CameraPosition cameraPosition = kakao.CameraPosition(
        kakao.LatLng(place.latitude, place.longitude),
        initialZoom.toInt(),
        rotationAngle: 0.0,
      );
      final kakao.CameraUpdate cameraUpdate = kakao.CameraUpdate.newCameraPos(
        cameraPosition,
      );
      await _mapController!.moveCamera(cameraUpdate);

      // 회전을 0도로 명시적으로 리셋하여 북쪽이 위로 오도록 보장
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

    final AppResult<route_planning.RouteSegment> result = await _facade
        .createRoute
        .execute(
          _route.pins[_route.pins.length - 2].position,
          _route.pins[_route.pins.length - 1].position,
        );

    if (mounted) {
      setState(() {
        _isRouteLoading = false;
      });

      switch (result) {
        case final AppSuccess<route_planning.RouteSegment> success:
          setState(() {
            // addSegment가 자동으로 핀 위치도 업데이트
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
    if (_isRouteLoading) return;

    // managePins UseCase는 여전히 LatLng 리스트를 받으므로 변환 필요
    final List<latlong2.LatLng> pinPositions =
        _route.pins.map((RoutePin pin) => pin.position).toList();

    if (_facade.managePins.shouldAddPin(_isButtonPressed, pinPositions)) {
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

      final List<latlong2.LatLng> updatedPinPositions =
          _route.pins.map((RoutePin pin) => pin.position).toList();
      if (_facade.managePins.shouldGetRoute(updatedPinPositions)) {
        _getRoute();
      }
    }
  }

  Future<void> _removeLastPin({bool shouldRemoveRouteSegment = true}) async {
    setState(() {
      _route = _route.removeLastPin(removeSegment: shouldRemoveRouteSegment);
    });

    // 핀과 경로를 업데이트하기 전에 상태가 확실히 반영되도록 함
    await Future<void>.delayed(const Duration(milliseconds: 50));

    _updateRoutePins();
    // 세그먼트가 제거되었든 아니든, 항상 경로를 업데이트하여
    // 지도에 표시된 경로가 _route.segments와 일치하도록 함
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

    // 모든 경로 세그먼트의 포인트들을 수집
    final List<kakao.LatLng> fitPoints = <kakao.LatLng>[];
    for (final route_planning.RouteSegment segment in _route.segments) {
      fitPoints.addAll(
        segment.points
            .map(
              (latlong2.LatLng point) =>
                  kakao.LatLng(point.latitude, point.longitude),
            )
            .toList(),
      );
    }

    if (fitPoints.isNotEmpty) {
      // 최소/최대 좌표 계산
      double minLat = fitPoints[0].latitude;
      double maxLat = fitPoints[0].latitude;
      double minLng = fitPoints[0].longitude;
      double maxLng = fitPoints[0].longitude;
      for (final kakao.LatLng point in fitPoints) {
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }

      // 중앙 좌표로 대략적인 범위 맞춤
      final double centerLat = (minLat + maxLat) / 2;
      final double centerLng = (minLng + maxLng) / 2;
      final kakao.CameraUpdate cameraUpdate = kakao
          .CameraUpdate.newCenterPosition(kakao.LatLng(centerLat, centerLng));
      await _mapController!.moveCamera(cameraUpdate);
    }
  }

  Future<void> _fitMapToSearchResults(SearchResult searchResult) async {
    if (searchResult.places.isEmpty || _mapController == null) return;

    // 단일 장소인 경우 해당 장소로 이동
    if (searchResult.places.length == 1) {
      _moveToPlace(searchResult.places.first);
      return;
    }

    // 모든 검색 결과를 포함하는 범위로 맞춤
    final List<kakao.LatLng> fitPoints =
        searchResult.places
            .map((Place place) => kakao.LatLng(place.latitude, place.longitude))
            .toList();

    if (fitPoints.isNotEmpty) {
      // fitMapPoints를 사용하여 모든 검색 결과가 보이도록 카메라 조정
      // padding은 픽셀 단위 (20px 여유 공간)
      final kakao.CameraUpdate cameraUpdate = kakao.CameraUpdate.fitMapPoints(
        fitPoints,
        padding: 20,
      );
      await _mapController!.moveCamera(cameraUpdate);

      // 회전을 0도로 명시적으로 리셋하여 북쪽이 위로 오도록 보장
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

  // kakao_map_sdk 오버레이 업데이트 메서드들
  Future<void> _updateCurrentLocationMarker() async {
    if (_mapController == null || !mounted) return;

    try {
      // 기존 현위치 POI 제거
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
          // 현위치 마커 추가 - icon을 제공하여 NSNull 크래시 방지
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
      // 기존 경로 핀 POI 제거
      for (final kakao.Poi poi in _routePinPois) {
        try {
          await _mapController!.labelLayer.removePoi(poi);
        } catch (e) {
          debugPrint('경로 핀 POI 제거 실패: $e');
        }
      }
      _routePinPois.clear();

      if (!mounted || _mapController == null) return;

      final SemanticColors colors = context.semanticColor;

      for (int i = 0; i < _route.pins.length; i++) {
        if (!mounted || _mapController == null) return;

        try {
          final RoutePin pin = _route.pins[i];
          // RoutePinMarker를 사용하여 숫자가 들어간 원 마커 생성
          final RoutePinMarker marker = RoutePinMarker(
            index: i,
            hasWaypoint: pin.hasWaypoint,
            waypoint: pin.waypoint,
          );

          // SemanticTheme로 감싸서 KImage.fromWidget에 전달
          final kakao.KImage iconImage = await kakao.KImage.fromWidget(
            SemanticTheme(data: colors, child: marker),
            const Size(24, 24),
          );

          final kakao.Poi poi = await _mapController!.labelLayer.addPoi(
            kakao.LatLng(pin.position.latitude, pin.position.longitude),
            style: kakao.PoiStyle(icon: iconImage),
          );
          if (mounted) {
            _routePinPois.add(poi);
          }
        } catch (e) {
          debugPrint('경로 핀 추가 실패 (인덱스 $i): $e');
        }
      }
    } catch (e) {
      debugPrint('경로 핀 업데이트 실패: $e');
    }
  }

  Future<void> _updateRouteLines() async {
    if (_mapController == null || !mounted) return;

    try {
      // 기존 경로 Route를 개별적으로 제거
      for (final kakao.Route route in _routeRoutes) {
        try {
          await _mapController!.routeLayer.removeRoute(route);
        } catch (e) {
          // Route 제거 실패 시 무시하고 계속 진행
        }
      }

      // 기존 경로 리스트 클리어
      _routeRoutes.clear();

      // Route 제거 후 약간의 딜레이 추가
      await Future<void>.delayed(const Duration(milliseconds: 50));

      if (!mounted || _mapController == null) return;

      // POLYLINE 데이터 리스트(_route.segments)를 기반으로 모든 경로 다시 추가
      final SemanticColors colors = context.semanticColor;

      for (int i = 0; i < _route.segments.length; i++) {
        if (!mounted || _mapController == null) return;

        final route_planning.RouteSegment segment = _route.segments[i];

        // segment.points가 비어있으면 건너뛰기
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
            MapConstants.polylineStrokeWidth,
          );

          final kakao.Route route = await _mapController!.routeLayer.addRoute(
            points,
            routeStyle,
          );

          if (mounted) {
            _routeRoutes.add(route);
          }
        } catch (e) {
          // 경로 라인 추가 실패 시 무시하고 계속 진행
        }
      }
    } catch (e) {
      // 경로 라인 업데이트 실패 시 무시
    }
  }

  Future<void> _updateSearchPlaceMarkers() async {
    if (_mapController == null || !mounted) return;

    try {
      // 기존 검색 장소 POI 제거
      for (final kakao.Poi poi in _searchPlacePois) {
        try {
          await _mapController!.labelLayer.removePoi(poi);
        } catch (e) {
          debugPrint('검색 장소 POI 제거 실패: $e');
        }
      }
      _searchPlacePois.clear();

      if (!mounted || _mapController == null) return;

      final SemanticColors colors = context.semanticColor;

      // 단일 선택된 장소 마커 - Icons.place (40 사이즈)
      if (_selectedPlace != null) {
        try {
          final kakao.KImage placeIcon = await kakao.KImage.fromWidget(
            Icon(Icons.place, color: colors.primaryNormal, size: 36),
            const Size(36, 36),
          );
          final kakao.Poi poi = await _mapController!.labelLayer.addPoi(
            kakao.LatLng(_selectedPlace!.latitude, _selectedPlace!.longitude),
            style: kakao.PoiStyle(icon: placeIcon),
          );
          if (mounted) {
            _searchPlacePois.add(poi);
          }
        } catch (e) {
          debugPrint('선택된 장소 마커 추가 실패: $e');
        }
      }

      // 검색 결과 전체 장소 마커들 - Icons.location_on (34 사이즈)
      for (int i = 0; i < _searchedPlaces.length; i++) {
        if (!mounted || _mapController == null) return;

        try {
          final Place place = _searchedPlaces[i];
          final kakao.KImage locationIcon = await kakao.KImage.fromWidget(
            Icon(Icons.location_on, color: colors.primaryNormal, size: 34),
            const Size(34, 34),
          );
          final kakao.Poi poi = await _mapController!.labelLayer.addPoi(
            kakao.LatLng(place.latitude, place.longitude),
            style: kakao.PoiStyle(icon: locationIcon),
          );
          if (mounted) {
            _searchPlacePois.add(poi);
          }
        } catch (e) {
          debugPrint('검색 결과 마커 추가 실패 (인덱스 $i): $e');
        }
      }
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
                      // 지도 준비 후 마커 업데이트 (순차적으로 실행하여 크래시 방지)
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
                    onMapClick: (kakao.KPoint point, kakao.LatLng latLng) {
                      // 지도 클릭 시 핀 추가
                      // 버튼 토글 직후(500ms 이내)에는 핀 추가를 무시하여
                      // 버튼 터치로 인한 의도치 않은 핀 추가 방지
                      if (_isButtonPressed && mounted) {
                        final DateTime now = DateTime.now();
                        if (_lastButtonToggleTime != null) {
                          final Duration timeSinceToggle = now.difference(
                            _lastButtonToggleTime!,
                          );
                          if (timeSinceToggle.inMilliseconds < 500) {
                            // 버튼 토글 직후(500ms 이내)라면 핀 추가 무시
                            return;
                          }
                        }
                        _addPin(
                          latlong2.LatLng(latLng.latitude, latLng.longitude),
                        );
                      }
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
                              // 버튼 클릭 시간을 먼저 기록 (setState 전에)
                              // 이렇게 하면 버튼 터치가 지도로 전달되어도 핀 추가를 방지할 수 있음
                              _lastButtonToggleTime = DateTime.now();

                              // 상태 변경 (내부에서도 시간을 기록하지만, 여기서 먼저 기록하여 확실히 방지)
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
