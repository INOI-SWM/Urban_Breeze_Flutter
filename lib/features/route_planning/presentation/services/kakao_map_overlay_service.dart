import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:urban_breeze/core/theme/app_theme.dart';
import 'package:urban_breeze/features/place_search/domain/entities/place.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_pin.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/route_segment.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/waypoint.dart'
    as route_planning;
import 'package:urban_breeze/features/route_planning/presentation/mappers/lat_lng_mapper.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/widgets/marker/route_pin_marker.dart';

/// Kakao Map 오버레이(POI, Route) 관리를 담당하는 서비스
class KakaoMapOverlayService {
  KakaoMapOverlayService({
    required kakao.KakaoMapController mapController,
    required SemanticColors colors,
  }) : _mapController = mapController,
       _colors = colors;

  final kakao.KakaoMapController _mapController;
  SemanticColors _colors;

  /// 컬러 업데이트 (테마 변경 시 호출)
  void updateColors(SemanticColors colors) {
    _colors = colors;
  }

  /// 현재 위치 마커 추가
  Future<kakao.Poi> addCurrentLocationMarker(latlong2.LatLng position) async {
    final kakao.KImage iconImage = kakao.KImage.fromAsset(
      'assets/icons/png/current_location_pin.png',
      24,
      24,
    );
    return _mapController.labelLayer.addPoi(
      LatLngMapper.toKakaoLatLng(position),
      style: kakao.PoiStyle(icon: iconImage),
    );
  }

  /// 경로 핀 마커 추가
  Future<kakao.Poi> addRoutePinMarker(RoutePin pin, int index) async {
    final RoutePinMarker marker = RoutePinMarker(
      index: index,
      hasWaypoint: pin.hasWaypoint,
      waypoint: pin.waypoint,
    );

    final kakao.KImage iconImage = await kakao.KImage.fromWidget(
      SemanticTheme(data: _colors, child: marker),
      const Size(24, 24),
    );

    return _mapController.labelLayer.addPoi(
      LatLngMapper.toKakaoLatLng(pin.position),
      style: kakao.PoiStyle(icon: iconImage),
    );
  }

  /// 선택된 장소 마커 추가
  Future<kakao.Poi> addSelectedPlaceMarker(Place place) async {
    final kakao.KImage placeIcon = await kakao.KImage.fromWidget(
      Icon(Icons.place, color: _colors.primaryNormal, size: 36),
      const Size(36, 36),
    );
    return _mapController.labelLayer.addPoi(
      kakao.LatLng(place.latitude, place.longitude),
      style: kakao.PoiStyle(icon: placeIcon),
    );
  }

  /// 검색 결과 장소 마커 추가
  Future<kakao.Poi> addSearchPlaceMarker(Place place) async {
    final kakao.KImage locationIcon = await kakao.KImage.fromWidget(
      Icon(Icons.location_on, color: _colors.primaryNormal, size: 34),
      const Size(34, 34),
    );
    return _mapController.labelLayer.addPoi(
      kakao.LatLng(place.latitude, place.longitude),
      style: kakao.PoiStyle(icon: locationIcon),
    );
  }

  /// 시작점 마커 추가 (자전거 아이콘)
  Future<kakao.Poi> addStartMarker(
    latlong2.LatLng position,
    Color color,
  ) async {
    final kakao.KImage startIcon = await kakao.KImage.fromWidget(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: Icon(Icons.directions_bike, color: color, size: 14),
      ),
      const Size(20, 20),
    );
    return _mapController.labelLayer.addPoi(
      LatLngMapper.toKakaoLatLng(position),
      style: kakao.PoiStyle(icon: startIcon),
    );
  }

  /// 끝점 마커 추가 (스포츠 점수 아이콘)
  Future<kakao.Poi> addEndMarker(latlong2.LatLng position, Color color) async {
    final kakao.KImage endIcon = await kakao.KImage.fromWidget(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: Icon(Icons.sports_score, color: color, size: 14),
      ),
      const Size(20, 20),
    );
    return _mapController.labelLayer.addPoi(
      LatLngMapper.toKakaoLatLng(position),
      style: kakao.PoiStyle(icon: endIcon),
    );
  }

  /// 웨이포인트 마커 추가
  Future<kakao.Poi> addWaypointMarker(
    latlong2.LatLng position,
    int index,
    route_planning.Waypoint waypoint,
  ) async {
    final RoutePinMarker marker = RoutePinMarker(
      index: index,
      hasWaypoint: true,
      waypoint: waypoint,
    );

    final kakao.KImage iconImage = await kakao.KImage.fromWidget(
      SemanticTheme(data: _colors, child: marker),
      Size(marker.markerSize, marker.markerSize),
    );

    return _mapController.labelLayer.addPoi(
      LatLngMapper.toKakaoLatLng(position),
      style: kakao.PoiStyle(icon: iconImage),
    );
  }

  /// 경로 라인 추가
  Future<kakao.Route> addRouteLine(RouteSegment segment) async {
    if (segment.points.isEmpty) {
      throw ArgumentError('Route segment points cannot be empty');
    }

    final List<kakao.LatLng> points = LatLngMapper.toKakaoLatLngList(
      segment.points,
    );

    final kakao.RouteStyle routeStyle = kakao.RouteStyle(
      Color(_colors.primaryNormal.toARGB32()),
      6.0,
    );

    return _mapController.routeLayer.addRoute(points, routeStyle);
  }

  /// POI 제거
  Future<void> removePoi(kakao.Poi poi) async {
    await _mapController.labelLayer.removePoi(poi);
  }

  /// Route 제거
  Future<void> removeRoute(kakao.Route route) async {
    await _mapController.routeLayer.removeRoute(route);
  }

  /// 모든 POI 제거
  Future<void> removeAllPois(List<kakao.Poi> pois) async {
    final List<Future<void>> removeFutures =
        pois.map((kakao.Poi poi) async {
          try {
            await removePoi(poi);
          } catch (e) {
            debugPrint('POI 제거 실패: $e');
          }
        }).toList();
    await Future.wait(removeFutures);
  }

  /// 모든 Route 제거
  Future<void> removeAllRoutes(List<kakao.Route> routes) async {
    final List<Future<void>> removeFutures =
        routes.map((kakao.Route route) async {
          try {
            await removeRoute(route);
          } catch (e) {
            debugPrint('Route 제거 실패: $e');
          }
        }).toList();
    await Future.wait(removeFutures);
  }
}
