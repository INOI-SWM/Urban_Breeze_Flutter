/// 추천 코스 필드 변환 유틸리티
/// 한글 표시명과 API 코드 간의 변환을 담당
class RecommendedCourseFieldConverter {
  const RecommendedCourseFieldConverter._();

  /// 한글 지역명을 API 코드로 매핑
  static const Map<String, String> _regionMapping = <String, String>{
    '서울/경기': 'SEOUL',
    '강원': 'GANGWON',
    '충청': 'CHUNGCHEONG',
    '전라': 'JEOLLA',
    '경상': 'GYEONGSANG',
    '제주': 'JEJU',
  };

  /// API 코드를 한글 지역명으로 매핑 (역매핑)
  static const Map<String, String> _reverseRegionMapping = <String, String>{
    'SEOUL': '서울/경기',
    'GANGWON': '강원',
    'CHUNGCHEONG': '충청',
    'JEOLLA': '전라',
    'GYEONGSANG': '경상',
    'JEJU': '제주',
  };

  /// 한글 난이도를 API 코드로 매핑
  static const Map<String, String> _difficultyMapping = <String, String>{
    '쉬움': 'EASY',
    '보통': 'MEDIUM',
    '어려움': 'HARD',
  };

  /// API 코드를 한글 난이도로 매핑 (역매핑)
  static const Map<String, String> _reverseDifficultyMapping = <String, String>{
    'EASY': '쉬움',
    'MEDIUM': '보통',
    'HARD': '어려움',
  };

  /// 한글 추천타입을 API 코드로 매핑
  static const Map<String, String> _recommendationTypeMapping =
      <String, String>{
        '국토 종주': 'CROSS_COUNTRY',
        '대회 코스': 'COMPETITION',
        '유명 코스': 'FAMOUS',
      };

  /// API 코드를 한글 추천타입으로 매핑 (역매핑)
  static const Map<String, String> _reverseRecommendationTypeMapping =
      <String, String>{
        'CROSS_COUNTRY': '국토 종주',
        'COMPETITION': '대회 코스',
        'FAMOUS': '유명 코스',
      };

  // === 지역 변환 ===

  /// 한글 지역명을 API 코드로 변환
  static String convertRegionToApi(String korean) {
    return _regionMapping[korean] ?? korean;
  }

  /// API 코드를 한글 지역명으로 변환
  static String convertRegionFromApi(String apiCode) {
    return _reverseRegionMapping[apiCode] ?? apiCode;
  }

  /// 한글 지역명 리스트를 API 코드 리스트로 변환
  static List<String>? convertRegionsToApi(List<String>? koreanRegions) {
    if (koreanRegions == null) return null;

    final List<String> apiRegions =
        koreanRegions
            .where((String region) => region != '전체') // '전체' 제외
            .map(convertRegionToApi)
            .toList();

    return apiRegions.isEmpty ? null : apiRegions;
  }

  /// API 코드 리스트를 한글 지역명 리스트로 변환
  static List<String>? convertRegionsFromApi(List<String>? apiRegions) {
    if (apiRegions == null) return null;

    return apiRegions.map(convertRegionFromApi).toList();
  }

  // === 난이도 변환 ===

  /// 한글 난이도를 API 코드로 변환
  static String convertDifficultyToApi(String korean) {
    return _difficultyMapping[korean] ?? korean;
  }

  /// API 코드를 한글 난이도로 변환
  static String convertDifficultyFromApi(String apiCode) {
    return _reverseDifficultyMapping[apiCode] ?? apiCode;
  }

  /// 한글 난이도 리스트를 API 코드 리스트로 변환
  static List<String>? convertDifficultiestoApi(
    List<String>? koreanDifficulties,
  ) {
    if (koreanDifficulties == null) return null;

    final List<String> apiDifficulties =
        koreanDifficulties
            .where((String difficulty) => difficulty != '전체') // '전체' 제외
            .map(convertDifficultyToApi)
            .toList();

    return apiDifficulties.isEmpty ? null : apiDifficulties;
  }

  /// API 코드 리스트를 한글 난이도 리스트로 변환
  static List<String>? convertDifficultiesFromApi(
    List<String>? apiDifficulties,
  ) {
    if (apiDifficulties == null) return null;

    return apiDifficulties.map(convertDifficultyFromApi).toList();
  }

  // === 추천타입 변환 ===

  /// 한글 추천타입을 API 코드로 변환
  static String convertRecommendationTypeToApi(String korean) {
    return _recommendationTypeMapping[korean] ?? korean;
  }

  /// API 코드를 한글 추천타입으로 변환
  static String convertRecommendationTypeFromApi(String apiCode) {
    return _reverseRecommendationTypeMapping[apiCode] ?? apiCode;
  }

  /// 한글 추천타입 리스트를 API 코드 리스트로 변환
  static List<String>? convertRecommendationTypesToApi(
    List<String>? koreanTypes,
  ) {
    if (koreanTypes == null) return null;

    final List<String> apiTypes =
        koreanTypes
            .where((String type) => type != '전체') // '전체' 제외
            .map(convertRecommendationTypeToApi)
            .toList();

    return apiTypes.isEmpty ? null : apiTypes;
  }

  /// API 코드 리스트를 한글 추천타입 리스트로 변환
  static List<String>? convertRecommendationTypesFromApi(
    List<String>? apiTypes,
  ) {
    if (apiTypes == null) return null;

    return apiTypes.map(convertRecommendationTypeFromApi).toList();
  }

  // === 카테고리 분류 유틸리티 ===

  /// 문자열이 지역 카테고리인지 확인
  static bool isRegion(String value) {
    return _regionMapping.containsKey(value);
  }

  /// 문자열이 난이도 카테고리인지 확인
  static bool isDifficulty(String value) {
    return _difficultyMapping.containsKey(value);
  }

  /// 문자열이 추천타입 카테고리인지 확인
  static bool isRecommendationType(String value) {
    return _recommendationTypeMapping.containsKey(value);
  }

  /// 카테고리 집합에서 지역들만 추출
  static List<String> extractRegions(Set<String> categories) {
    return categories.where(isRegion).toList();
  }

  /// 카테고리 집합에서 난이도들만 추출
  static List<String> extractDifficulties(Set<String> categories) {
    return categories.where(isDifficulty).toList();
  }

  /// 카테고리 집합에서 추천타입들만 추출
  static List<String> extractRecommendationTypes(Set<String> categories) {
    return categories.where(isRecommendationType).toList();
  }
}
