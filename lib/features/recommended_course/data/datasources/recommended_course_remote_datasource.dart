import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_detail_response_model.dart';
import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_list_data_model.dart';
import 'package:urban_breeze/features/recommended_course/data/models/recommended_course_request_model.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

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

  Future<ApiResponseModel<RecommendedCourseDetailResponseModel>>
  getCourseDetail(String routeId) async {
    final http.Response response = await get(
      ApiEndpoints.recommendationDetail(routeId),
    );

    final Map<String, dynamic> json = decodeResponse(response);
    return ApiResponseModel<RecommendedCourseDetailResponseModel>.fromJson(
      json,
      (Map<String, dynamic> dataJson) =>
          RecommendedCourseDetailResponseModel.fromJson(dataJson),
    );
  }

  Future<void> addToMyRoute(String routeId) async {
    await post(
      ApiEndpoints.addMyRoute,
      body: <String, String>{'routeId': routeId},
    );
  }
}
