import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/data/datasources/apple_health_workout_datasource.dart';
import 'package:urban_breeze/features/workout_history/data/models/apple_health_workout_model.dart';

class ImportAppleHealthWorkoutsUseCase {
  const ImportAppleHealthWorkoutsUseCase({
    required this.appleHealthWorkoutDataSource,
  });

  final AppleHealthWorkoutDataSource appleHealthWorkoutDataSource;

  Future<AppResult<void>> execute({
    required List<AppleHealthWorkoutModel> workouts,
  }) async {
    try {
      final ImportAppleHealthWorkoutsRequestModel request =
          ImportAppleHealthWorkoutsRequestModel(workouts: workouts);

      await appleHealthWorkoutDataSource.importAppleHealthWorkouts(request);

      return const AppSuccess<void>(null);
    } catch (e) {
      // 413 에러인 경우 구체적인 메시지 제공
      final String errorMessage = e.toString();
      if (errorMessage.contains('413')) {
        return const AppFailure<void>(
          ServerException('업로드 실패 다시 시도해주세요.', '413'),
        );
      }

      // 기타 Apple Health Kit 관련 예외
      return AppFailure<void>(ServerException(errorMessage));
    }
  }
}
