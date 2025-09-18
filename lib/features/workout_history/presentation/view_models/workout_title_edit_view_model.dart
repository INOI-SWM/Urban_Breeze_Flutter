import 'package:flutter/foundation.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/update_workout_title_use_case.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/shared/utils/error_message_mapper.dart';

class WorkoutTitleEditState {
  const WorkoutTitleEditState({
    this.title = '',
    this.isEditing = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final String title;
  final bool isEditing;
  final bool isLoading;
  final String? errorMessage;

  WorkoutTitleEditState copyWith({
    String? title,
    bool? isEditing,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WorkoutTitleEditState(
      title: title ?? this.title,
      isEditing: isEditing ?? this.isEditing,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class WorkoutTitleEditViewModel extends ValueNotifier<WorkoutTitleEditState> {
  WorkoutTitleEditViewModel({
    required this.updateWorkoutTitleUseCase,
    required String initialTitle,
    required this.currentWorkoutDetail,
  }) : super(WorkoutTitleEditState(title: initialTitle));

  final UpdateWorkoutTitleUseCase updateWorkoutTitleUseCase;
  final WorkoutDetail currentWorkoutDetail;

  static const int _maxTitleLength = 60;

  void startEditing() {
    _updateState(isEditing: true, errorMessage: null);
  }

  void cancelEditing() {
    _updateState(isEditing: false, errorMessage: null);
  }

  // 공통 상태 업데이트 메서드
  void _updateState({
    String? title,
    bool? isEditing,
    bool? isLoading,
    String? errorMessage,
  }) {
    value = value.copyWith(
      title: title,
      isEditing: isEditing,
      isLoading: isLoading,
      errorMessage: errorMessage,
    );
  }

  Future<AppResult<WorkoutDetail>> saveTitle({
    required String workoutId,
    required String newTitle,
  }) async {
    final String trimmedTitle = newTitle.trim();

    // 변경사항이 없으면 그냥 편집 모드 종료
    if (trimmedTitle == value.title.trim()) {
      _updateState(isEditing: false, errorMessage: null);
      return AppSuccess<WorkoutDetail>(currentWorkoutDetail);
    }

    // 로딩 시작
    _updateState(isLoading: true, errorMessage: null);

    final AppResult<WorkoutDetail> result = await updateWorkoutTitleUseCase
        .execute(
          workoutId: workoutId,
          title: trimmedTitle,
          currentWorkoutDetail: currentWorkoutDetail,
        );

    if (result is AppSuccess<WorkoutDetail>) {
      // 성공 시 상태 업데이트
      _updateState(
        title: trimmedTitle,
        isEditing: false,
        isLoading: false,
        errorMessage: null,
      );
      return result;
    } else if (result is AppFailure<WorkoutDetail>) {
      // 실패 시 에러 메시지 설정
      final String errorMessage = _getErrorMessage(result.exception);
      _updateState(isLoading: false, errorMessage: errorMessage);
      return result;
    }

    return result;
  }

  String _getErrorMessage(BaseDomainException exception) {
    return ErrorMessageMapper.getErrorMessage(exception);
  }

  bool get canSave => value.title.trim().isNotEmpty && !value.isLoading;
  bool get hasChanges => value.isEditing;
  int get maxTitleLength => _maxTitleLength;
}
