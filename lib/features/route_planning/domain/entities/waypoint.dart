import 'package:latlong2/latlong.dart';

enum WaypointType {
  generic, // 일반
  summit, // 정상
  valley, // 계곡
  water, // 물
  food, // 보급
  danger, // 위험
  left, // 좌회전
  right, // 우회전
  straight, // 직진
  firstAid, // 응급처치
  category4, // 4등급 오르막
  category3, // 3등급 오르막
  category2, // 2등급 오르막
  category1, // 1등급 오르막
  horsCategory, // 특등급 오르막 (HC)
  sprint, // 스프린트 지점
}

extension WaypointTypeExtension on WaypointType {
  String get displayName {
    switch (this) {
      case WaypointType.generic:
        return '일반';
      case WaypointType.summit:
        return '정상';
      case WaypointType.valley:
        return '계곡';
      case WaypointType.water:
        return '물';
      case WaypointType.food:
        return '보급';
      case WaypointType.danger:
        return '위험';
      case WaypointType.left:
        return '좌회전';
      case WaypointType.right:
        return '우회전';
      case WaypointType.straight:
        return '직진';
      case WaypointType.firstAid:
        return '응급처치';
      case WaypointType.category4:
        return '4등급 오르막';
      case WaypointType.category3:
        return '3등급 오르막';
      case WaypointType.category2:
        return '2등급 오르막';
      case WaypointType.category1:
        return '1등급 오르막';
      case WaypointType.horsCategory:
        return '무제한급 오르막';
      case WaypointType.sprint:
        return '스프린트';
    }
  }

  String get iconName {
    switch (this) {
      case WaypointType.generic:
        return 'generic';
      case WaypointType.summit:
        return 'summit';
      case WaypointType.valley:
        return 'valley';
      case WaypointType.water:
        return 'water';
      case WaypointType.food:
        return 'food';
      case WaypointType.danger:
        return 'danger';
      case WaypointType.left:
        return 'left';
      case WaypointType.right:
        return 'right';
      case WaypointType.straight:
        return 'straight';
      case WaypointType.firstAid:
        return 'first_aid';
      case WaypointType.category4:
        return 'category_4';
      case WaypointType.category3:
        return 'category_3';
      case WaypointType.category2:
        return 'category_2';
      case WaypointType.category1:
        return 'category_1';
      case WaypointType.horsCategory:
        return 'hors_category';
      case WaypointType.sprint:
        return 'sprint';
    }
  }

  String get description {
    switch (this) {
      case WaypointType.generic:
        return '일반';
      case WaypointType.summit:
        return '정상';
      case WaypointType.valley:
        return '계곡';
      case WaypointType.water:
        return '물';
      case WaypointType.food:
        return '보급';
      case WaypointType.danger:
        return '위험';
      case WaypointType.left:
        return '좌회전';
      case WaypointType.right:
        return '우회전';
      case WaypointType.straight:
        return '직진';
      case WaypointType.firstAid:
        return '응급처치';
      case WaypointType.category4:
        return '4등급 오르막';
      case WaypointType.category3:
        return '3등급 오르막';
      case WaypointType.category2:
        return '2등급 오르막';
      case WaypointType.category1:
        return '1등급 오르막';
      case WaypointType.horsCategory:
        return '무제한급 오르막';
      case WaypointType.sprint:
        return '스프린트';
    }
  }
}

class Waypoint {
  const Waypoint({
    required this.id,
    required this.position,
    required this.type,
    required this.title,
    this.description,
    this.isOptional = false,
  });

  final String id;
  final LatLng position;
  final WaypointType type;
  final String title;
  final String? description;
  final bool isOptional; // 선택적 waypoint인지

  Waypoint copyWith({
    String? id,
    LatLng? position,
    WaypointType? type,
    String? title,
    String? description,
  }) {
    return Waypoint(
      id: id ?? this.id,
      position: position ?? this.position,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Waypoint && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Waypoint(id: $id, title: $title, type: ${type.displayName}, position: $position)';
  }
}
