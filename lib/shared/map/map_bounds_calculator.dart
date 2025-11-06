import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart' as kakao;
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:urban_breeze/features/route_planning/presentation/mappers/lat_lng_mapper.dart';

class MapBoundsCalculator {
  MapBoundsCalculator._();

  /// bbox와 바텀시트, 상단 safezone을 고려하여 fitPoints를 계산합니다.
  ///
  /// [bbox] 경계 상자 [minLng, minLat, maxLng, maxLat]
  /// [bottomSheetSize] 바텀시트 크기 (0.0 ~ 1.0)
  /// [context] MediaQuery를 위한 BuildContext
  ///
  /// Returns: fitMapPoints에 사용할 수 있는 LatLng 리스트
  static List<latlong2.LatLng> calculateFitPoints(
    List<double> bbox,
    double bottomSheetSize, {
    BuildContext? context,
  }) {
    final List<latlong2.LatLng> fitPoints = <latlong2.LatLng>[
      latlong2.LatLng(bbox[1], bbox[0]), // minLat, minLng
      latlong2.LatLng(bbox[3], bbox[2]), // maxLat, maxLng
    ];

    final double latDiff = bbox[3] - bbox[1];

    // 바텀시트 확장
    final double bottomExpansionFactor = bottomSheetSize * 2.4;
    final double adjustedMinLatBottom =
        bbox[1] - (latDiff * bottomExpansionFactor);
    fitPoints.add(latlong2.LatLng(adjustedMinLatBottom, bbox[0]));

    // 상단 safezone 확장
    if (context != null) {
      final MediaQueryData mediaQuery = MediaQuery.of(context);
      final double screenHeight = mediaQuery.size.height;
      final double topSafeArea = mediaQuery.padding.top;
      final double topSafeAreaRatio = topSafeArea / screenHeight;
      final double topExpansionFactor = topSafeAreaRatio * 2.4;
      final double adjustedMaxLatTop = bbox[3] + (latDiff * topExpansionFactor);
      fitPoints.add(latlong2.LatLng(adjustedMaxLatTop, bbox[0]));
      fitPoints.add(latlong2.LatLng(adjustedMaxLatTop, bbox[2]));
    }

    return fitPoints;
  }

  /// 포인트 리스트에서 bbox를 계산합니다.
  ///
  /// [points] 위도/경도 포인트 리스트
  ///
  /// Returns: [minLng, minLat, maxLng, maxLat]
  static List<double> calculateBboxFromPoints(List<latlong2.LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final latlong2.LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return <double>[minLng, minLat, maxLng, maxLat];
  }

  /// bbox와 바텀시트, 상단 safezone을 고려하여 카메라를 이동시킵니다.
  ///
  /// [mapController] 카카오맵 컨트롤러
  /// [bbox] 경계 상자 [minLng, minLat, maxLng, maxLat]
  /// [bottomSheetSize] 바텀시트 크기 (0.0 ~ 1.0)
  /// [context] MediaQuery를 위한 BuildContext
  /// [padding] fitMapPoints의 padding (기본값: 20)
  static Future<void> fitMapToBounds(
    kakao.KakaoMapController mapController,
    List<double> bbox,
    double bottomSheetSize, {
    BuildContext? context,
    int padding = 20,
  }) async {
    final List<latlong2.LatLng> fitPoints = calculateFitPoints(
      bbox,
      bottomSheetSize,
      context: context,
    );

    final List<kakao.LatLng> kakaoPoints =
        fitPoints
            .map((latlong2.LatLng p) => LatLngMapper.toKakaoLatLng(p))
            .toList();

    final kakao.CameraUpdate cameraUpdate = kakao.CameraUpdate.fitMapPoints(
      kakaoPoints,
      padding: padding,
    );

    await mapController.moveCamera(cameraUpdate);
  }
}
