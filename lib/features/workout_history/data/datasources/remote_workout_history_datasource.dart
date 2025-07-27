import 'package:flutter/material.dart';
import 'package:ridingmate/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';
import 'package:ridingmate/shared/api/data/datasources/base_remote_datasource.dart';

import '../models/workout_title_update_request_model.dart';

class RemoteWorkoutHistoryDatasource extends BaseRemoteDataSource {
  RemoteWorkoutHistoryDatasource({super.client});

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
      //   '/api/activities/$workoutId/title',
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
