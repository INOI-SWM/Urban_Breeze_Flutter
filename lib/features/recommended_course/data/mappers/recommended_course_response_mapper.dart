import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_list_data_model.dart';
import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_response_model.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_list.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

/// 추천 코스 응답 관련 매핑
/// API 응답 모델을 도메인 엔티티로 변환하는 역할을 담당
class RecommendedCourseResponseMapper {
  const RecommendedCourseResponseMapper._();

  /// 응답 모델을 도메인 엔티티로 변환
  static RecommendedCourse fromResponseModel(
    RecommendedCourseResponseModel model,
  ) {
    return RecommendedCourse(
      routeId: model.routeId,
      title: model.title,
      description: model.description,
      distanceKm: model.distanceKm,
      durationMinutes: model.durationMinutes,
      elevationGain: model.elevationGain,
      region: model.region,
      difficulty: model.difficulty,
      recommendationType: model.recommendationType,
      thumbnailImagePath: model.thumbnailImagePath,
    );
  }

  /// API 응답을 도메인 리스트 엔티티로 변환
  static RecommendedCourseList fromApiResponse(
    ApiResponseModel<RecommendedCourseListDataModel> response,
  ) {
    final RecommendedCourseListDataModel data = response.data;

    return RecommendedCourseList(
      courses: data.recommendations.map(fromResponseModel).toList(),
      currentPage: data.pagination.currentPage,
      totalPages: data.pagination.totalPages,
      totalElements: data.pagination.totalElements,
      size: data.pagination.size,
      hasNext: data.pagination.hasNext,
      hasPrevious: data.pagination.hasPrevious,
    );
  }
}
