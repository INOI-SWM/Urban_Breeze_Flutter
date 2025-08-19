import 'package:ridingmate/features/my_route/data/models/pagination_model.dart';
import 'package:ridingmate/features/recommended_course/data/models/recommended_course_model.dart';

class RecommendedCourseListDataModel {
  const RecommendedCourseListDataModel({
    required this.recommendations,
    required this.pagination,
  });

  factory RecommendedCourseListDataModel.fromJson(Map<String, dynamic> json) {
    return RecommendedCourseListDataModel(
      recommendations:
          (json['recommendations'] as List<dynamic>)
              .map(
                (dynamic courseJson) => RecommendedCourseResponseModel.fromJson(
                  courseJson as Map<String, dynamic>,
                ),
              )
              .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  final List<RecommendedCourseResponseModel> recommendations;
  final PaginationModel pagination;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'recommendations':
          recommendations
              .map((RecommendedCourseResponseModel course) => course.toJson())
              .toList(),
      'pagination': pagination.toJson(),
    };
  }
}
