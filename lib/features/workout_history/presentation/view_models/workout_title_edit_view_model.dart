import 'package:flutter/foundation.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/update_workout_title_use_case.dart';
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
  }) : super(WorkoutTitleEditState(title: initialTitle));

  final UpdateWorkoutTitleUseCase updateWorkoutTitleUseCase;

  static const int _maxTitleLength = 60;

  void startEditing() {
    value = value.copyWith(isEditing: true, errorMessage: null);
  }

  void cancelEditing() {
    value = value.copyWith(isEditing: false, errorMessage: null);
  }

  bool _isTitleChanged(String newTitle) {
    return newTitle.trim() != value.title.trim();
  }

  Future<AppResult<void>> saveTitle({
    required String workoutId,
    required String newTitle,
  }) async {
    // 변경사항이 없으면 그냥 편집 모드 종료
    if (!_isTitleChanged(newTitle)) {
      value = value.copyWith(isEditing: false, errorMessage: null);
      return const AppSuccess<void>(null);
    }

    // 로딩 시작
    value = value.copyWith(isLoading: true, errorMessage: null);

    try {
      final AppResult<void> result = await updateWorkoutTitleUseCase.execute(
        workoutId: workoutId,
        title: newTitle.trim(),
      );

      if (result is AppSuccess<void>) {
        // 성공 시 상태 업데이트
        value = value.copyWith(
          title: newTitle.trim(),
          isEditing: false,
          isLoading: false,
          errorMessage: null,
        );
        return result;
      } else if (result is AppFailure<void>) {
        // 실패 시 에러 메시지 설정
        final String errorMessage = _getErrorMessage(result.exception);
        value = value.copyWith(isLoading: false, errorMessage: errorMessage);
        return result;
      }

      return result;
    } catch (e) {
      final String errorMessage = '알 수 없는 오류가 발생했습니다: ${e.toString()}';
      value = value.copyWith(isLoading: false, errorMessage: errorMessage);
      return AppFailure<void>(Exception(errorMessage) as BaseDomainException);
    }
  }

  String _getErrorMessage(BaseDomainException exception) {
    return ErrorMessageMapper.getErrorMessage(exception);
  }

  bool get canSave => value.title.trim().isNotEmpty && !value.isLoading;
  bool get hasChanges => value.isEditing;
  int get maxTitleLength => _maxTitleLength;
}
