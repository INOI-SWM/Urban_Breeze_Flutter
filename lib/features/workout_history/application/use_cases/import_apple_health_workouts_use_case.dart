import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/data/datasources/apple_health_workout_datasource.dart';
import 'package:urban_breeze/features/workout_history/data/models/apple_health_workout_model.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';

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
      return AppFailure<void>(TerraApiException(e.toString()));
    }
  }
}
