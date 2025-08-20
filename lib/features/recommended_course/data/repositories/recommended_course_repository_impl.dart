import 'package:urban_breeze/features/recommended_course/data/datasources/recommended_course_remote_datasource.dart';
import 'package:urban_breeze/features/recommended_course/data/mappers/recommended_course_request_mapper.dart';
import 'package:urban_breeze/features/recommended_course/data/mappers/recommended_course_response_mapper.dart';
import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_list_data_model.dart';
import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_request_model.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_filter.dart';
import 'package:urban_breeze/features/recommended_course/domain/entities/recommended_course_list.dart';
import 'package:urban_breeze/features/recommended_course/domain/repositories/recommended_course_repository.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

class RecommendedCourseRepositoryImpl implements RecommendedCourseRepository {
  const RecommendedCourseRepositoryImpl({
    required RecommendedCourseRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final RecommendedCourseRemoteDataSource _remoteDataSource;

  @override
  Future<RecommendedCourseList> getRecommendedCourseList(
    RecommendedCourseFilter filter,
  ) async {
    final RecommendedCourseRequestModel requestModel =
        RecommendedCourseRequestMapper.fromFilter(filter);

    final ApiResponseModel<RecommendedCourseListDataModel> response =
        await _remoteDataSource.getRecommendedCourseList(requestModel);

    return RecommendedCourseResponseMapper.fromApiResponse(response);
  }
}
