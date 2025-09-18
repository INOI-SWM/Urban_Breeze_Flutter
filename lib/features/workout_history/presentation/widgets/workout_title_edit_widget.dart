import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/update_workout_title_use_case.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/workout_detail.dart';
import 'package:urban_breeze/features/workout_history/presentation/view_models/workout_title_edit_view_model.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:urban_breeze/shared/design_system/widgets/modal/modal_show.dart';
import 'package:urban_breeze/shared/design_system/widgets/text_field/inline_edit_text_field.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class WorkoutTitleEditWidget extends ConsumerStatefulWidget {
  const WorkoutTitleEditWidget({
    super.key,
    required this.workoutId,
    required this.initialTitle,
    required this.currentWorkoutDetail,
    this.onTitleUpdated,
  });

  final String workoutId;
  final String initialTitle;
  final WorkoutDetail currentWorkoutDetail;
  final void Function(WorkoutDetail updatedWorkoutDetail)? onTitleUpdated;

  @override
  ConsumerState<WorkoutTitleEditWidget> createState() =>
      _WorkoutTitleEditWidgetState();
}

class _WorkoutTitleEditWidgetState extends ConsumerState<WorkoutTitleEditWidget>
    with ErrorDisplayMixin {
  static const String _titleSavedMessage = '제목이 저장되었습니다';
  static const String _unsavedChangesMessage = '저장되지 않는 내용은 모두 사라집니다.';

  late final WorkoutTitleEditViewModel _viewModel;
  String? _lastDisplayedErrorMessage;

  @override
  void initState() {
    super.initState();
    final String initialTitle = widget.initialTitle;
    final UpdateWorkoutTitleUseCase useCase = ref.read(
      updateWorkoutTitleUseCaseProvider,
    );
    _viewModel = WorkoutTitleEditViewModel(
      updateWorkoutTitleUseCase: useCase,
      initialTitle: initialTitle,
      currentWorkoutDetail: widget.currentWorkoutDetail,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _startEditing() {
    _viewModel.startEditing();
  }

  void _cancelEditing() {
    _viewModel.cancelEditing();
  }

  Future<void> _saveTitle(String newTitle) async {
    final AppResult<WorkoutDetail> result = await _viewModel.saveTitle(
      workoutId: widget.workoutId,
      newTitle: newTitle,
    );

    if (mounted) {
      if (result.isSuccess) {
        showSuccessMessage(context, _titleSavedMessage);
        // 제목 업데이트 성공 시 콜백 호출
        widget.onTitleUpdated?.call(result.dataOrNull!);
      } else if (result.isFailure) {
        // ViewModel에서 이미 에러 메시지를 상태에 설정했으므로
        // 여기서는 추가 처리가 필요 없음
      }
    }
  }

  void _showSaveConfirmationDialog(String newTitle) {
    final WorkoutTitleEditState state = _viewModel.value;

    // ViewModel에서 검증
    if (state.errorMessage != null) {
      return; // 이미 에러 메시지가 표시됨
    }

    // 변경사항이 없으면 그냥 편집 모드 종료
    if (newTitle.trim() == state.title.trim()) {
      _cancelEditing();
      return;
    }

    ModalShow.show(
      context: context,
      content: Text(
        _unsavedChangesMessage,
        textAlign: TextAlign.center,
        style: AppTextStyles.label1.readingBold,
      ),
      primaryButtonText: '저장',
      secondaryButtonText: '취소',
      onPrimaryButtonPressed: () {
        _saveTitle(newTitle);
      },
      onSecondaryButtonPressed: _cancelEditing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return ValueListenableBuilder<WorkoutTitleEditState>(
      valueListenable: _viewModel,
      builder: (
        BuildContext context,
        WorkoutTitleEditState state,
        Widget? child,
      ) {
        if (state.errorMessage != null &&
            state.errorMessage != _lastDisplayedErrorMessage) {
          _lastDisplayedErrorMessage = state.errorMessage;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showErrorMessage(context, state.errorMessage!);
          });
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child:
                  state.isEditing
                      ? InlineEditTextField(
                        initialText: state.title,
                        onSaved: (String newTitle) {
                          _showSaveConfirmationDialog(newTitle);
                        },
                        onSubmitted: (String newTitle) {
                          _saveTitle(newTitle);
                        },
                        textStyle: AppTextStyles.title3.bold.copyWith(
                          color: colors.labelStrong,
                        ),
                        maxLength: 60,
                      )
                      : Text(
                        state.title,
                        style: AppTextStyles.title3.bold.copyWith(
                          color: colors.labelStrong,
                        ),
                      ),
            ),
            if (!state.isEditing)
              CustomIconButton(
                icon: Icons.edit_outlined,
                onTap: state.isLoading ? () {} : _startEditing,
              ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        );
      },
    );
  }
}
