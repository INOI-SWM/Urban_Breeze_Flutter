import 'dart:io';

import 'package:urban_breeze/features/workout_history/data/models/upload_workout_images_response_model.dart';
import 'package:urban_breeze/features/workout_history/data/models/workout_detail_response_model.dart';
import 'package:urban_breeze/features/workout_history/data/models/workout_list_response_model.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/activity_image.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_list.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/workout_sort_type.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/workout_history_repository.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

import '../datasources/remote_workout_history_datasource.dart';
import '../mappers/upload_result_mapper.dart';
import '../mappers/workout_detail_mapper.dart';
import '../mappers/workout_mapper.dart';

class WorkoutHistoryRepositoryImpl implements WorkoutHistoryRepository {
  const WorkoutHistoryRepositoryImpl({required this.remoteDataSource});

  final RemoteWorkoutHistoryDataSource remoteDataSource;

  @override
  Future<WorkoutList> getWorkoutList({
    int page = 0,
    int size = 10,
    WorkoutSortType sortType = WorkoutSortType.startedAtDesc,
  }) async {
    final ApiResponseModel<WorkoutListResponseModel> response =
        await remoteDataSource.getWorkoutList(
          page: page,
          size: size,
          sortType: sortType,
        );

    return WorkoutMapper.fromApiResponse(response);
  }

  @override
  Future<WorkoutDetail> getWorkoutDetail({required String activityId}) async {
    final ApiResponseModel<WorkoutDetailResponseModel> response =
        await remoteDataSource.getWorkoutDetail(activityId: activityId);

    return WorkoutDetailMapper.fromApiResponse(response);
  }

  @override
  Future<void> updateWorkoutTitle({
    required String workoutId,
    required String title,
  }) async {
    await remoteDataSource.updateWorkoutTitle(
      workoutId: workoutId,
      title: title,
    );
  }

  @override
  Future<List<ActivityImage>> uploadWorkoutImages({
    required String activityId,
    required List<File> imageFiles,
  }) async {
    final ApiResponseModel<UploadWorkoutImagesResponseModel> response =
        await remoteDataSource.uploadWorkoutImages(
          activityId: activityId,
          imageFiles: imageFiles,
        );

    return UploadResultMapper.fromApiResponse(response);
  }

  @override
  Future<void> deleteWorkoutImage({
    required String activityId,
    required int imageId,
  }) async {
    await remoteDataSource.deleteWorkoutImage(
      activityId: activityId,
      imageId: imageId,
    );
  }

  @override
  Future<void> deleteWorkout(String activityId) async {
    await remoteDataSource.deleteWorkout(activityId);
  }
}
