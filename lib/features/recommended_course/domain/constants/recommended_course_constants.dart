/// 추천 코스 관련 상수들
/// 카테고리 분류 및 필터링에 사용되는 상수 정의
class RecommendedCourseConstants {
  const RecommendedCourseConstants._();

  /// 지역 카테고리 목록
  static const Set<String> regions = <String>{
    '서울/경기',
    '강원',
    '충청',
    '전라',
    '경상',
    '제주',
  };

  /// 난이도 카테고리 목록
  static const Set<String> difficulties = <String>{'쉬움', '보통', '어려움'};

  /// 추천타입 카테고리 목록
  static const Set<String> recommendationTypes = <String>{
    '국토 종주',
    '대회 코스',
    '유명 코스',
  };

  // === 필터 옵션 (UI용) ===

  /// 지역 필터 옵션 ('전체' 포함)
  static const List<String> regionFilterOptions = <String>[
    '전체',
    '서울',
    '강원',
    '충청',
    '전라',
    '경상',
    '제주',
  ];

  /// 난이도 필터 옵션 ('전체' 포함)
  static const List<String> difficultyFilterOptions = <String>[
    '전체',
    '쉬움',
    '보통',
    '어려움',
  ];

  /// 추천타입 필터 옵션 ('전체' 포함)
  static const List<String> recommendationTypeFilterOptions = <String>[
    '전체',
    '국토 종주',
    '대회 코스',
    '유명 코스',
  ];

  // === API 매핑 ===

  /// 한글 지역명 → API 코드 매핑
  static const Map<String, String> regionToApiMapping = <String, String>{
    '서울': 'SEOUL',
    '강원': 'GANGWON',
    '충청': 'CHUNGCHEONG',
    '전라': 'JEOLLA',
    '경상': 'GYEONGSANG',
    '제주': 'JEJU',
  };

  /// API 코드 → 한글 지역명 매핑
  static const Map<String, String> apiToRegionMapping = <String, String>{
    'SEOUL': '서울',
    'GANGWON': '강원',
    'CHUNGCHEONG': '충청',
    'JEOLLA': '전라',
    'GYEONGSANG': '경상',
    'JEJU': '제주',
  };

  /// 한글 난이도 → API 코드 매핑
  static const Map<String, String> difficultyToApiMapping = <String, String>{
    '쉬움': 'EASY',
    '보통': 'MEDIUM',
    '어려움': 'HARD',
  };

  /// API 코드 → 한글 난이도 매핑
  static const Map<String, String> apiToDifficultyMapping = <String, String>{
    'EASY': '쉬움',
    'MEDIUM': '보통',
    'HARD': '어려움',
  };

  /// 한글 추천타입 → API 코드 매핑
  static const Map<String, String> recommendationTypeToApiMapping =
      <String, String>{
        '국토 종주': 'CROSS_COUNTRY',
        '대회 코스': 'COMPETITION',
        '유명 코스': 'FAMOUS',
      };

  /// API 코드 → 한글 추천타입 매핑
  static const Map<String, String> apiToRecommendationTypeMapping =
      <String, String>{
        'CROSS_COUNTRY': '국토 종주',
        'COMPETITION': '대회 코스',
        'FAMOUS': '유명 코스',
      };

  /// API 기본값들
  static const int defaultPageSize = 10;
}
