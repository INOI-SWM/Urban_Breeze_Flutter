/// 추천 코스 관련 상수들
/// 카테고리 분류 및 필터링에 사용되는 상수 정의
class RecommendedCourseConstants {
  const RecommendedCourseConstants._();

  /// 지역 카테고리 목록
  static const Set<String> regions = <String>{
    '서울특별시',
    '인천광역시',
    '경기도',
    '강원특별자치도',
    '대전광역시',
    '세종특별자치시',
    '충청북도',
    '충청남도',
    '대구광역시',
    '경상북도',
    '광주광역시',
    '전북특별자치도',
    '전라남도',
    '부산광역시',
    '울산광역시',
    '경상남도',
    '제주특별자치도',
    '그 외 지역',
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
    '서울특별시',
    '인천광역시',
    '경기도',
    '강원특별자치도',
    '대전광역시',
    '세종특별자치시',
    '충청북도',
    '충청남도',
    '대구광역시',
    '경상북도',
    '광주광역시',
    '전북특별자치도',
    '전라남도',
    '부산광역시',
    '울산광역시',
    '경상남도',
    '제주특별자치도',
    '그 외 지역',
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
    '서울특별시': 'SEOUL',
    '인천광역시': 'INCHEON',
    '경기도': 'GYEONGGI',
    '강원특별자치도': 'GANGWON',
    '대전광역시': 'DAEJEON',
    '세종특별자치시': 'SEJONG',
    '충청북도': 'CHUNGBUK',
    '충청남도': 'CHUNGNAM',
    '대구광역시': 'DAEGU',
    '경상북도': 'GYEONGBUK',
    '광주광역시': 'GWANGJU',
    '전북특별자치도': 'JEONBUK',
    '전라남도': 'JEONNAM',
    '부산광역시': 'BUSAN',
    '울산광역시': 'ULSAN',
    '경상남도': 'GYEONGNAM',
    '제주특별자치도': 'JEJU',
    '그 외 지역': 'ETC',
  };

  /// API 코드 → 한글 지역명 매핑
  static const Map<String, String> apiToRegionMapping = <String, String>{
    'SEOUL': '서울특별시',
    'INCHEON': '인천광역시',
    'GYEONGGI': '경기도',
    'GANGWON': '강원특별자치도',
    'DAEJEON': '대전광역시',
    'SEJONG': '세종특별자치시',
    'CHUNGBUK': '충청북도',
    'CHUNGNAM': '충청남도',
    'DAEGU': '대구광역시',
    'GYEONGBUK': '경상북도',
    'GWANGJU': '광주광역시',
    'JEONBUK': '전북특별자치도',
    'JEONNAM': '전라남도',
    'BUSAN': '부산광역시',
    'ULSAN': '울산광역시',
    'GYEONGNAM': '경상남도',
    'JEJU': '제주특별자치도',
    'ETC': '그 외 지역',
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
