import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/features/workout_history/domain/enums/workout_sort_type.dart';
import 'package:urban_breeze/features/workout_history/domain/exceptions/workout_history_domain_exceptions.dart';
import 'package:urban_breeze/shared/api/data/constants/api_endpoints.dart';
import 'package:urban_breeze/shared/api/data/datasources/base_remote_datasource.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';
import 'package:urban_breeze/shared/utils/image_upload_utils.dart';

import '../models/upload_workout_images_response_model.dart';
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
    debugPrint('json: $json');

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

  /// 운동 사진 업로드
  Future<ApiResponseModel<UploadWorkoutImagesResponseModel>>
  uploadWorkoutImages({
    required String activityId,
    required List<File> imageFiles,
  }) async {
    try {
      // 여러 이미지 파일을 MultipartFile로 변환
      final List<http.MultipartFile> multipartFiles = <http.MultipartFile>[];

      for (int i = 0; i < imageFiles.length; i++) {
        final http.MultipartFile multipartFile =
            await ImageUploadUtils.createImageMultipartFile(
              imageFiles[i],
              'files',
              maxSizeInMB: 20,
            );
        multipartFiles.add(multipartFile);
      }

      final http.StreamedResponse response = await postMultipartFiles(
        ApiEndpoints.workoutImages(activityId),
        fields: <String, String>{}, // 추가 필드가 필요하면 여기에
        files: multipartFiles,
      );

      // StreamedResponse를 Response로 변환
      final http.Response responseConverted = await http.Response.fromStream(
        response,
      );
      final Map<String, dynamic> responseData = decodeResponse(
        responseConverted,
      );

      return ApiResponseModel<UploadWorkoutImagesResponseModel>.fromJson(
        responseData,
        (Map<String, dynamic> json) =>
            UploadWorkoutImagesResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteWorkoutImage({
    required String activityId,
    required int imageId,
  }) async {
    try {
      await delete(ApiEndpoints.workoutImageDetail(activityId, imageId));
    } catch (e) {
      rethrow;
    }
  }

  /// 운동 기록 삭제
  Future<void> deleteWorkout(String activityId) async {
    try {
      final http.Response response = await delete(
        ApiEndpoints.workoutDelete(activityId),
      );
      final int statusCode = response.statusCode;

      if (statusCode == 200 || statusCode == 204) {
        return; // 삭제 성공
      } else {
        final Map<String, dynamic> jsonMap = decodeResponse(response);
        final String errorMessage =
            (jsonMap['errorMessage'] ?? jsonMap['message'] ?? '운동 기록 삭제 실패')
                .toString();
        throw ServerException('운동 기록 삭제 실패 ($statusCode): $errorMessage');
      }
    } on ServerException {
      rethrow;
    }
    // BaseRemoteDataSource에서 NetworkException, ParsingException 처리
  }
}
