import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:urban_breeze/features/route_planning/presentation/services/kakao_map_overlay_service.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/map/map_bounds_calculator.dart';

/// 카카오맵 상태 관리를 위한 Mixin
///
/// 공통 상태 변수와 메서드를 제공합니다.
mixin KakaoMapStateMixin<T extends StatefulWidget> on State<T> {
  kakao.KakaoMapController? _mapController;
  KakaoMapOverlayService? _mapOverlayService;
  final List<kakao.Poi> _routePois = <kakao.Poi>[];
  final List<kakao.Route> _routeRoutes = <kakao.Route>[];
  bool _hasUserDraggedMap = false;

  /// 맵 컨트롤러 접근자
  kakao.KakaoMapController? get mapController => _mapController;

  /// 맵 오버레이 서비스 접근자
  KakaoMapOverlayService? get mapOverlayService => _mapOverlayService;

  /// 경로 POI 리스트 접근자
  List<kakao.Poi> get routePois => _routePois;

  /// 경로 Route 리스트 접근자
  List<kakao.Route> get routeRoutes => _routeRoutes;

  /// 사용자가 지도를 드래그했는지 여부
  bool get hasUserDraggedMap => _hasUserDraggedMap;

  /// 맵 초기화
  ///
  /// [controller] 카카오맵 컨트롤러
  /// [colors] 시맨틱 컬러
  void initializeMap(
    kakao.KakaoMapController controller,
    SemanticColors colors,
  ) {
    _mapController = controller;
    _mapOverlayService = KakaoMapOverlayService(
      mapController: controller,
      colors: colors,
    );
  }

  /// 맵 바운드 업데이트
  ///
  /// [bbox] 경계 상자 [minLng, minLat, maxLng, maxLat]
  /// [bottomSheetSize] 바텀시트 크기 (0.0 ~ 1.0)
  /// [context] BuildContext (선택사항, 상단 safe area 계산용)
  Future<void> updateMapBounds(
    List<double> bbox,
    double bottomSheetSize, {
    BuildContext? context,
  }) async {
    if (_mapController == null || _hasUserDraggedMap) return;

    await MapBoundsCalculator.fitMapToBounds(
      _mapController!,
      bbox,
      bottomSheetSize,
      context: context,
    );
  }

  /// 모든 오버레이 제거
  Future<void> clearAllOverlays() async {
    if (_mapOverlayService == null) return;

    await _mapOverlayService!.removeAllPois(_routePois);
    await _mapOverlayService!.removeAllRoutes(_routeRoutes);
    _routePois.clear();
    _routeRoutes.clear();
  }

  /// POI 추가
  void addPoi(kakao.Poi poi) {
    _routePois.add(poi);
  }

  /// Route 추가
  void addRoute(kakao.Route route) {
    _routeRoutes.add(route);
  }

  /// 사용자 드래그 상태 설정
  void setUserDraggedMap(bool value) {
    _hasUserDraggedMap = value;
  }

  /// 사용자 드래그 상태 리셋
  void resetUserDraggedMap() {
    _hasUserDraggedMap = false;
  }

  /// 컬러 업데이트 (테마 변경 시 호출)
  void updateColors(SemanticColors colors) {
    _mapOverlayService?.updateColors(colors);
  }

  @override
  void dispose() {
    _mapController = null;
    _mapOverlayService = null;
    super.dispose();
  }
}
