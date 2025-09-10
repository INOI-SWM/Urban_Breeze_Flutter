import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/workout_history/application/use_cases/update_workout_title_use_case.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
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
    required this.initialIndex,
  });

  final String workoutId;
  final int initialIndex;

  @override
  ConsumerState<WorkoutTitleEditWidget> createState() =>
      _WorkoutTitleEditWidgetState();
}

class _WorkoutTitleEditWidgetState extends ConsumerState<WorkoutTitleEditWidget>
    with ErrorDisplayMixin {
  static const int _maxTitleLength = 60;
  static const String _emptyTitleMessage = '제목은 비어있을 수 없습니다';
  static const String _titleSavedMessage = '제목이 저장되었습니다';
  static const String _unknownErrorMessage = '알 수 없는 오류가 발생했습니다';
  static const String _unsavedChangesMessage = '저장되지 않는 내용은 모두 사라집니다.';

  bool _isEditingTitle = false;
  late String _workoutTitle;

  @override
  void initState() {
    super.initState();
    _workoutTitle = '운동기록 ${widget.initialIndex + 1}';
  }

  bool _isValidTitle(String title) {
    return title.trim().isNotEmpty;
  }

  bool _isTitleChanged(String newTitle) {
    return newTitle.trim() != _workoutTitle.trim();
  }

  void _startEditing() {
    setState(() {
      _isEditingTitle = true;
    });
  }

  Future<void> _saveTitle(String newTitle) async {
    if (!_isValidTitle(newTitle)) {
      showErrorMessage(context, _emptyTitleMessage);
      return;
    }

    try {
      await _performTitleUpdate(newTitle);
      _updateTitleState(newTitle);
      if (mounted) {
        showSuccessMessage(context, _titleSavedMessage);
      }
    } catch (e) {
      if (mounted) {
        showErrorMessage(context, '$_unknownErrorMessage: ${e.toString()}');
      }
    }
  }

  Future<void> _performTitleUpdate(String newTitle) async {
    final UpdateWorkoutTitleUseCase useCase = ref.read(
      updateWorkoutTitleUseCaseProvider,
    );
    await useCase.execute(workoutId: widget.workoutId, title: newTitle);
  }

  void _updateTitleState(String newTitle) {
    setState(() {
      _workoutTitle = newTitle;
      _isEditingTitle = false;
    });
  }

  void _exitEditingMode() {
    setState(() {
      _isEditingTitle = false;
    });
  }

  void _showSaveConfirmationDialog(String newTitle) {
    if (!_isValidTitle(newTitle)) {
      showErrorMessage(context, _emptyTitleMessage);
      return;
    }

    if (!_isTitleChanged(newTitle)) {
      _exitEditingMode();
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
      onSecondaryButtonPressed: _exitEditingMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child:
              _isEditingTitle
                  ? InlineEditTextField(
                    initialText: _workoutTitle,
                    onSaved: (String newTitle) {
                      _showSaveConfirmationDialog(newTitle);
                    },
                    onSubmitted: (String newTitle) {
                      _saveTitle(newTitle);
                    },
                    textStyle: AppTextStyles.title3.bold.copyWith(
                      color: colors.labelStrong,
                    ),
                    maxLength: _maxTitleLength,
                  )
                  : Text(
                    _workoutTitle,
                    style: AppTextStyles.title3.bold.copyWith(
                      color: colors.labelStrong,
                    ),
                  ),
        ),
        if (!_isEditingTitle)
          CustomIconButton(icon: Icons.edit_outlined, onTap: _startEditing),
      ],
    );
  }
}
