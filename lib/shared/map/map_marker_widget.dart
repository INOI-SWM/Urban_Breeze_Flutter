import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';

class MapMarkerWidget {
  /// 시작점 마커 생성 (자전거 아이콘)
  static Marker createStartMarker(
    LatLng point,
    Color color,
    SemanticColors colors,
  ) {
    return Marker(
      point: point,
      width: 24,
      height: 24,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: Icon(Icons.directions_bike, color: color, size: 16),
      ),
    );
  }

  /// 끝점 마커 생성 (스포츠 점수 아이콘)
  static Marker createEndMarker(
    LatLng point,
    Color color,
    SemanticColors colors,
  ) {
    return Marker(
      point: point,
      width: 24,
      height: 24,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: Icon(Icons.sports_score, color: color, size: 16),
      ),
    );
  }

  /// 일반 마커 생성 (커스텀 아이콘)
  static Marker createCustomMarker(
    LatLng point,
    Color color,
    IconData icon,
    SemanticColors colors,
  ) {
    return Marker(
      point: point,
      width: 24,
      height: 24,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
