import 'package:flutter/material.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

import '../models/workout_title_update_request_model.dart';

class RemoteWorkoutHistoryDataSource extends BaseRemoteDataSource {
  RemoteWorkoutHistoryDataSource({super.client});

  Future<void> updateWorkoutTitle({
    required String workoutId,
    required String title,
  }) async {
    try {
      final WorkoutTitleUpdateRequestModel requestModel =
          WorkoutTitleUpdateRequestModel(title: title);

      debugPrint(requestModel.toJson().toString());
      // TODO: 서버 연동 후 주석 해제
      // final http.Response response = await patch(
      //   ApiEndpoints.routeTitle(workoutId),
      //   body: requestModel.toJson(),
      // );

      // final int statusCode = response.statusCode;

      // 성공적으로 완료된 경우 (200, 204 등)
      return;
    } on WorkoutTitleUpdateException {
      rethrow;
    }
    // BaseRemoteDataSource에서 NetworkException, ParsingException 처리
  }
}
