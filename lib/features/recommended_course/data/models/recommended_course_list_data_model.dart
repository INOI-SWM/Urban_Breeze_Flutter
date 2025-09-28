import 'package:urban_breeze/features/my_route/data/models/pagination_model.dart';
import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_response_model.dart';

class RecommendedCourseFilterRangeModel {
  const RecommendedCourseFilterRangeModel({
    required this.minDistance,
    required this.maxDistance,
    required this.minElevationGain,
    required this.maxElevationGain,
  });

  factory RecommendedCourseFilterRangeModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecommendedCourseFilterRangeModel(
      minDistance: (json['minDistance'] as num).toDouble(),
      maxDistance: (json['maxDistance'] as num).toDouble(),
      minElevationGain: (json['minElevationGain'] as num).toDouble(),
      maxElevationGain: (json['maxElevationGain'] as num).toDouble(),
    );
  }

  final double minDistance;
  final double maxDistance;
  final double minElevationGain;
  final double maxElevationGain;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'minDistance': minDistance,
      'maxDistance': maxDistance,
      'minElevationGain': minElevationGain,
      'maxElevationGain': maxElevationGain,
    };
  }
}

class RecommendedCourseListDataModel {
  const RecommendedCourseListDataModel({
    required this.recommendations,
    required this.pagination,
    required this.filterRange,
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
      filterRange: RecommendedCourseFilterRangeModel.fromJson(
        json['filterRange'] as Map<String, dynamic>,
      ),
    );
  }

  final List<RecommendedCourseResponseModel> recommendations;
  final PaginationModel pagination;
  final RecommendedCourseFilterRangeModel filterRange;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'recommendations':
          recommendations
              .map((RecommendedCourseResponseModel course) => course.toJson())
              .toList(),
      'pagination': pagination.toJson(),
      'filterRange': filterRange.toJson(),
    };
  }
}
