import 'dart:io';

import 'package:http/http.dart' as http;
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

      final http.Response response = await patch(
        '/api/activities/$workoutId/title',
        body: requestModel.toJson(),
      );

      final int statusCode = response.statusCode;

      if (statusCode == 200 || statusCode == 204) {
        return;
      }

      throw WorkoutTitleUpdateException('서버 오류 (${response.statusCode})');
    } on SocketException {
      throw const WorkoutHistoryNetworkException('인터넷 연결을 확인해주세요');
    } on FormatException {
      throw const WorkoutHistoryParsingException('서버 응답 데이터 형식이 잘못되었습니다');
    } on WorkoutHistoryDomainException {
      rethrow;
    } catch (e) {
      throw WorkoutTitleUpdateException('네트워크 오류: ${e.toString()}');
    }
  }
}
