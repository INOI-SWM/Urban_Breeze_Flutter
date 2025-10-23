import 'package:flutter/material.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/route_planning/domain/entities/waypoint.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';

class RoutePinMarker extends StatelessWidget {
  const RoutePinMarker({
    super.key,
    required this.index,
    this.hasWaypoint = false,
    this.waypoint,
  });
  final int index;
  final bool hasWaypoint;
  final Waypoint? waypoint;

  /// 마커의 실제 크기를 반환합니다.
  double get markerSize {
    if (hasWaypoint && waypoint != null) {
      return 28.0; // waypoint 마커 크기
    }
    return 24.0; // 일반 핀 크기
  }

  /// FlutterMap Marker에 필요한 크기를 반환합니다 (테두리와 그림자 고려).
  double get flutterMapMarkerSize {
    if (hasWaypoint && waypoint != null) {
      return 32.0; // 28px + 테두리(2px) + 그림자 여유공간(2px)
    }
    return 28.0; // 일반 핀은 여유공간 불필요
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    // Waypoint가 있는 경우 타입에 따른 색상과 아이콘 결정
    if (hasWaypoint && waypoint != null) {
      final Color backgroundColor = _getTypeColor(waypoint!.type, colors);
      final IconData icon = waypoint!.type.icon;

      return Container(
        width: markerSize,
        height: markerSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: colors.staticWhite, width: 2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Icon(icon, size: 16, color: colors.staticWhite)),
      );
    }

    // 일반 핀 (waypoint가 없는 경우)
    return Container(
      width: markerSize,
      height: markerSize,
      decoration: BoxDecoration(
        color: colors.accentBackgroundRedOrange,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: AppTextStyles.caption2.regular.copyWith(
            color: colors.staticWhite,
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(WaypointType type, SemanticColors colors) {
    switch (type) {
      case WaypointType.generic:
        return colors.primaryNormal;
      case WaypointType.summit:
        return colors.accentBackgroundPurple;
      case WaypointType.valley:
        return colors.accentBackgroundCyan;
      case WaypointType.water:
        return colors.accentBackgroundLightBlue;
      case WaypointType.food:
        return colors.accentBackgroundPink;
      case WaypointType.danger:
        return colors.statusNegative;
      case WaypointType.left:
      case WaypointType.right:
      case WaypointType.straight:
        return colors.accentBackgroundLime;
      case WaypointType.firstAid:
        return colors.statusPositive;
      case WaypointType.category4:
        return colors.accentBackgroundViolet;
      case WaypointType.category3:
        return colors.accentBackgroundRedOrange;
      case WaypointType.category2:
        return colors.accentBackgroundPink;
      case WaypointType.category1:
        return colors.accentBackgroundPurple;
      case WaypointType.horsCategory:
        return colors.staticBlack;
      case WaypointType.sprint:
        return colors.statusCautionary;
    }
  }
}
