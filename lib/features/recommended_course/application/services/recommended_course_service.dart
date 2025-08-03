import 'package:ridingmate/shared/design_system/widgets/thumbnail/thumbnail.dart';

class RecommendedCourseService {
  static Future<List<Map<String, dynamic>>> fetchRecommendedCourseList({
    Set<String>? categoryFilter,
  }) async {
    // TODO: 실제 API 호출
    // 임시 지연 시뮬레이션 (실제 네트워크 호출처럼)
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return _getMockRecommendedCourseList(categoryFilter);
  }

  /// 서버 구현 전까지 사용할 Mock 데이터
  static List<Map<String, dynamic>> _getMockRecommendedCourseList(
    Set<String>? categoryFilter,
  ) {
    final List<Map<String, dynamic>> allCourses = <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'rec1',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '추천',
        'title': '한강 자전거도로 코스',
        'distance': '25.5km',
        'elevation': '15m',
        'courseType': '강변',
        'region': '서울',
        'roadType': '아스팔트',
        'scenery': '강/하천',
        'difficulty': '쉬움',
      },
      <String, dynamic>{
        'id': 'rec2',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '추천',
        'title': '남한산성 둘레길',
        'distance': '18.2km',
        'elevation': '320m',
        'courseType': '산악',
        'region': '경기',
        'roadType': '혼합',
        'scenery': '산/언덕',
        'difficulty': '어려움',
      },
      <String, dynamic>{
        'id': 'rec3',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '추천',
        'title': '송도 센트럴파크 순환',
        'distance': '12.0km',
        'elevation': '25m',
        'courseType': '교외',
        'region': '인천',
        'roadType': '아스팔트',
        'scenery': '공원',
        'difficulty': '쉬움',
      },
      <String, dynamic>{
        'id': 'rec4',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '추천',
        'title': '양재천 벚꽃길',
        'distance': '15.8km',
        'elevation': '35m',
        'courseType': '강변',
        'region': '서울',
        'roadType': '아스팔트',
        'scenery': '강/하천',
        'difficulty': '쉬움',
      },
      <String, dynamic>{
        'id': 'rec5',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '추천',
        'title': '북한산 둘레길',
        'distance': '22.5km',
        'elevation': '450m',
        'courseType': '산악',
        'region': '서울',
        'roadType': '흙길',
        'scenery': '산/언덕',
        'difficulty': '어려움',
      },
      <String, dynamic>{
        'id': 'rec6',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '추천',
        'title': '청계천 야간 코스',
        'distance': '8.5km',
        'elevation': '10m',
        'courseType': '도심',
        'region': '서울',
        'roadType': '아스팔트',
        'scenery': '강/하천',
        'difficulty': '쉬움',
      },
      <String, dynamic>{
        'id': 'rec7',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '추천',
        'title': '월미바다열차길',
        'distance': '14.2km',
        'elevation': '40m',
        'courseType': '교외',
        'region': '인천',
        'roadType': '아스팔트',
        'scenery': '해안',
        'difficulty': '쉬움',
      },
      <String, dynamic>{
        'id': 'rec8',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '추천',
        'title': '운중천 자전거길',
        'distance': '19.5km',
        'elevation': '80m',
        'courseType': '교외',
        'region': '경기',
        'roadType': '아스팔트',
        'scenery': '강/하천',
        'difficulty': '중간',
      },
      <String, dynamic>{
        'id': 'rec9',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '추천',
        'title': '탄천 종주 코스',
        'distance': '35.0km',
        'elevation': '120m',
        'courseType': '강변',
        'region': '경기',
        'roadType': '아스팔트',
        'scenery': '강/하천',
        'difficulty': '중간',
      },
      <String, dynamic>{
        'id': 'rec10',
        'thumbnailPath': 'assets/images/png/thumbnail_r3_2.png',
        'sourceType': ThumbnailSourceType.asset,
        'badgeText': '추천',
        'title': '올림픽공원 힐링코스',
        'distance': '9.8km',
        'elevation': '30m',
        'courseType': '도심',
        'region': '서울',
        'roadType': '아스팔트',
        'scenery': '공원',
        'difficulty': '쉬움',
      },
    ];

    // 필터링 로직은 나중에 구현
    if (categoryFilter != null && categoryFilter.isNotEmpty) {
      // TODO: 필터 적용 로직 구현
      return allCourses;
    }

    return allCourses;
  }
}
