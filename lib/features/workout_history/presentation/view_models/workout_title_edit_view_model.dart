import 'package:flutter/foundation.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/exceptions/validation_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/update_workout_title_use_case.dart';

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
    if (exception is ValidationException) {
      switch (exception.code) {
        case 'WORKOUT_ID_EMPTY':
          return '운동 기록을 찾을 수 없습니다';
        case 'TITLE_EMPTY':
          return '제목은 비어있을 수 없습니다';
        case 'TITLE_TOO_LONG':
          final int maxLength =
              exception.data['maxLength'] as int? ?? _maxTitleLength;
          return '제목은 $maxLength자 이하로 입력해주세요';
        default:
          return '입력값이 올바르지 않습니다';
      }
    }

    return '제목 저장 중 오류가 발생했습니다';
  }

  bool get canSave => value.title.trim().isNotEmpty && !value.isLoading;
  bool get hasChanges => value.isEditing;
  int get maxTitleLength => _maxTitleLength;
}
