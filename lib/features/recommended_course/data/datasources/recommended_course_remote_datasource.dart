import 'package:http/http.dart' as http;
import 'package:ridingmate/features/recommended_course/data/models/recommended_course_filter_model.dart';
import 'package:ridingmate/features/recommended_course/data/models/recommended_course_list_data_model.dart';
import 'package:ridingmate/shared/api/data/constants/api_endpoints.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:ridingmate/shared/api/data/models/api_response_model.dart';

class RecommendedCourseRemoteDataSource extends BaseRemoteDataSource {
  RecommendedCourseRemoteDataSource({super.client});

  Future<ApiResponseModel<RecommendedCourseListDataModel>>
  getRecommendedCourseList(RecommendedCourseRequestModel filter) async {
    final http.Response response = await get(
      ApiEndpoints.recommendations,
      queryParameters: filter.toQueryParameters(),
    );

    final Map<String, dynamic> json = decodeResponse(response);

    return ApiResponseModel<RecommendedCourseListDataModel>.fromJson(
      json,
      (Map<String, dynamic> dataJson) =>
          RecommendedCourseListDataModel.fromJson(dataJson),
    );
  }
}
