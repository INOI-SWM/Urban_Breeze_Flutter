import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/workout_history/domain/enums/workout_sort_type.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

import '../models/workout_detail_response_model.dart';
import '../models/workout_list_response_model.dart';
import '../models/workout_title_update_request_model.dart';

class RemoteWorkoutHistoryDataSource extends BaseRemoteDataSource {
  RemoteWorkoutHistoryDataSource({super.client});

  Future<ApiResponseModel<WorkoutListResponseModel>> getWorkoutList({
    int page = 0,
    int size = 10,
    WorkoutSortType sortType = WorkoutSortType.startedAtDesc,
  }) async {
    final http.Response response = await get(
      ApiEndpoints.workoutList,
      queryParameters: <String, String>{
        'page': page.toString(),
        'size': size.toString(),
        'sortType': sortType.apiValue,
      },
    );

    final Map<String, dynamic> json = decodeResponse(response);

    return ApiResponseModel<WorkoutListResponseModel>.fromJson(
      json,
      (Map<String, dynamic> dataJson) =>
          WorkoutListResponseModel.fromJson(dataJson),
    );
  }

  Future<ApiResponseModel<WorkoutDetailResponseModel>> getWorkoutDetail({
    required String activityId,
  }) async {
    final http.Response response = await get(
      ApiEndpoints.workoutDetail(activityId),
    );

    final Map<String, dynamic> json = decodeResponse(response);

    return ApiResponseModel<WorkoutDetailResponseModel>.fromJson(
      json,
      (Map<String, dynamic> dataJson) =>
          WorkoutDetailResponseModel.fromJson(dataJson),
    );
  }

  Future<ApiResponseModel<void>> updateWorkoutTitle({
    required String workoutId,
    required String title,
  }) async {
    try {
      final WorkoutTitleUpdateRequestModel requestModel =
          WorkoutTitleUpdateRequestModel(title: title);

      final http.Response response = await put(
        ApiEndpoints.workoutTitle(workoutId),
        body: requestModel.toJson(),
      );

      final Map<String, dynamic> responseData = decodeResponse(response);

      return ApiResponseModel<void>.fromJson(
        responseData,
        (Map<String, dynamic> json) {},
      );
    } on WorkoutTitleUpdateException {
      rethrow;
    }
    // BaseRemoteDataSource에서 NetworkException, ParsingException 처리
  }
}
