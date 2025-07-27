import 'package:ridingmate/shared/design_system/widgets/thumbnail/thumbnail.dart';

class RouteListService {
  static Future<List<Map<String, dynamic>>> fetchRouteList({
    Set<String>? categoryFilter,
  }) async {
    // TODO: 실제 API 호출
    // 임시 지연 시뮬레이션 (실제 네트워크 호출처럼)
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return _getMockRouteList(categoryFilter);
  }

  /// 서버 구현 전까지 사용할 Mock 데이터
  static List<Map<String, dynamic>> _getMockRouteList(
    Set<String>? categoryFilter,
  ) {
    // TODO: 실제 유저 ID 가져오기
    const String currentUserId = 'user1';

    final List<Map<String, dynamic>> allRoutes = <Map<String, dynamic>>[
      <String, dynamic>{
        'id': '1',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '사용자1',
        'title': '한강 라이딩 코스',
        'createDate': '2025-01-01',
        'distance': '15.2km',
        'elevation': '50m',
        'creatorId': 'user1',
        'userName': '라이더김',
        'userProfileImage': 'https://via.placeholder.com/24',
      },
      <String, dynamic>{
        'id': '2',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '사용자1',
        'title': '남산 힐클라이밍',
        'createDate': '2024-12-28',
        'distance': '8.5km',
        'elevation': '200m',
        'creatorId': 'user1',
        'userName': '라이더김',
        'userProfileImage': 'https://via.placeholder.com/24',
      },
      <String, dynamic>{
        'id': '3',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '사용자2',
        'title': '올림픽공원 순환코스',
        'createDate': '2024-12-25',
        'distance': '12.0km',
        'elevation': '30m',
        'creatorId': 'user2',
        'userName': '노종빈',
        'userProfileImage': 'https://via.placeholder.com/24',
      },
      <String, dynamic>{
        'id': '4',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '사용자3',
        'title': '청계천 야간 라이딩',
        'createDate': '2024-12-20',
        'distance': '7.8km',
        'elevation': '20m',
        'creatorId': 'user3',
        'userName': '야간라이더',
        'userProfileImage': 'https://via.placeholder.com/24',
      },
      <String, dynamic>{
        'id': '5',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '사용자4',
        'title': '불광천 주간 라이딩',
        'createDate': '2024-11-20',
        'distance': '10.5km',
        'elevation': '10m',
        'creatorId': 'user4',
        'userName': '불광천러버',
        'userProfileImage': 'https://via.placeholder.com/24',
      },
    ];

    // creatorId를 기반으로 category 필드 추가
    final List<Map<String, dynamic>> routesWithCategory =
        allRoutes.map((Map<String, dynamic> route) {
          final String category =
              route['creatorId'] == currentUserId ? '내가 만든 경로' : '공유 받은 경로';

          return <String, dynamic>{...route, 'category': category};
        }).toList();

    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      return routesWithCategory
          .where(
            (Map<String, dynamic> route) =>
                categoryFilter.contains(route['category']),
          )
          .toList();
    }

    return routesWithCategory;
  }
}
