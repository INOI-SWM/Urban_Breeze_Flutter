abstract class WorkoutHistoryRepository {
  Future<void> updateWorkoutTitle({
    required String workoutId,
    required String title,
  });
}
