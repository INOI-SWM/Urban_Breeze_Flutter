import 'package:http/http.dart' as http;
import 'package:urban_breeze/features/workout_history/data/models/apple_health_workout_model.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';

class AppleHealthWorkoutDataSource extends BaseRemoteDataSource {
  AppleHealthWorkoutDataSource({super.client});

  /// Apple Health Kit 운동기록 업로드
  Future<void> importAppleHealthWorkouts(
    ImportAppleHealthWorkoutsRequestModel request,
  ) async {
    final http.Response response = await post(
      ApiEndpoints.importAppleHealthWorkouts,
      body: request.toJson(),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Apple Health 운동기록 업로드 실패: ${response.statusCode}');
    }
  }
}
