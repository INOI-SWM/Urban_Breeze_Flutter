import 'package:ridingmate/features/recommended_course/domain/constants/recommended_course_constants.dart';

/// 추천 코스 필드 변환 유틸리티
/// 한글 표시명과 API 코드 간의 변환을 담당
class RecommendedCourseFieldConverter {
  const RecommendedCourseFieldConverter._();

  // === 지역 변환 ===

  /// 한글 지역명을 API 코드로 변환
  static String convertRegionToApi(String korean) {
    return RecommendedCourseConstants.regionToApiMapping[korean] ?? korean;
  }

  /// API 코드를 한글 지역명으로 변환
  static String convertRegionFromApi(String apiCode) {
    return RecommendedCourseConstants.apiToRegionMapping[apiCode] ?? apiCode;
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
    return RecommendedCourseConstants.difficultyToApiMapping[korean] ?? korean;
  }

  /// API 코드를 한글 난이도로 변환
  static String convertDifficultyFromApi(String apiCode) {
    return RecommendedCourseConstants.apiToDifficultyMapping[apiCode] ??
        apiCode;
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
    return RecommendedCourseConstants.recommendationTypeToApiMapping[korean] ??
        korean;
  }

  /// API 코드를 한글 추천타입으로 변환
  static String convertRecommendationTypeFromApi(String apiCode) {
    return RecommendedCourseConstants.apiToRecommendationTypeMapping[apiCode] ??
        apiCode;
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
}
