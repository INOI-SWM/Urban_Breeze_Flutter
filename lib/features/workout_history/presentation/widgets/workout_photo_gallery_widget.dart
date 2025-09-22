import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/upload_result.dart';
import 'package:urban_breeze/shared/design_system/tokens/decorations/app_shadows.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_outlined.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class WorkoutPhotoGalleryWidget extends ConsumerStatefulWidget {
  const WorkoutPhotoGalleryWidget({super.key, required this.activityId});

  final String activityId;

  @override
  ConsumerState<WorkoutPhotoGalleryWidget> createState() =>
      _WorkoutPhotoGalleryWidgetState();
}

class _WorkoutPhotoGalleryWidgetState
    extends ConsumerState<WorkoutPhotoGalleryWidget>
    with ErrorDisplayMixin {
  static const int _maxPhotoCount = 30;
  static const String _maxPhotosMessage = '최대 30장까지만 추가할 수 있습니다.';

  static const double _containerSize = 112.0; // 전체 컨테이너 크기
  static const double _imageSize = 100.0; // 실제 이미지 크기
  static const double _imageTopOffset = 12.0; // 이미지 위치 조정
  static const double _itemSpacing = 4.0; // 아이템 간 간격
  static const double _listViewHeight = 112.0; // ListView 높이
  static const double _sectionSpacing = 8.0; // 섹션 간 간격

  static const double _deleteButtonSize = 24.0; // 삭제 버튼 크기
  static const double _deleteIconSize = 16.0; // 삭제 아이콘 크기

  final List<File> _selectedImages = <File>[];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  // 🔄 성능 최적화: 파일 해시 캐시 (메모리 효율적)
  final Map<String, String> _fileHashCache = <String, String>{};

  bool _canAddMorePhotos() {
    return _selectedImages.length < _maxPhotoCount && !_isUploading;
  }

  /// 선택된 이미지들을 서버에 업로드
  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty || _isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final AppResult<UploadResult> result = await ref
          .read(uploadWorkoutImagesUseCaseProvider)
          .execute(activityId: widget.activityId, imageFiles: _selectedImages);

      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        if (result.isSuccess) {
          final UploadResult uploadResult = result.dataOrNull!;
          showSuccessMessage(
            context,
            '${uploadResult.uploadedCount}장의 사진이 성공적으로 업로드되었습니다!',
          );
          // 업로드 완료 후 선택된 이미지들 초기화
          setState(() {
            _selectedImages.clear();
            _fileHashCache.clear();
          });
        } else {
          final String errorMessage =
              result.exceptionOrNull?.message ?? '업로드 중 오류가 발생했습니다.';
          showErrorMessage(context, errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        showErrorMessage(context, '업로드 중 예기치 못한 오류가 발생했습니다.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '사진',
          style: AppTextStyles.headline1.bold.copyWith(
            color: colors.labelNormal,
          ),
        ),
        const SizedBox(height: _sectionSpacing),
        Text(
          '${_selectedImages.length}/$_maxPhotoCount장 (최대 30장까지 추가 가능)',
          style: AppTextStyles.label1.readingBold.copyWith(
            color: colors.labelAlternative,
          ),
        ),
        const SizedBox(height: _sectionSpacing),
        SizedBox(
          height: _listViewHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: _containerSize,
                height: _containerSize,
                margin: const EdgeInsets.only(right: _itemSpacing),
                color: Colors.transparent,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: _imageTopOffset,
                      child: Container(
                        width: _imageSize,
                        height: _imageSize,
                        decoration: BoxDecoration(
                          color: colors.fillNormal,
                          border: Border.all(
                            color: colors.lineNormalNormal,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap:
                                _canAddMorePhotos()
                                    ? () {
                                      _addPhotoFromGallery();
                                    }
                                    : null,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 24,
                                  color:
                                      _canAddMorePhotos()
                                          ? colors.labelAlternative
                                          : colors.labelAlternative.withValues(
                                            alpha: 0.5,
                                          ),
                                ),
                                const SizedBox(height: 4),
                                if (!_canAddMorePhotos())
                                  Text(
                                    '최대',
                                    style: AppTextStyles.caption1.regular
                                        .copyWith(
                                          color: colors.labelAlternative
                                              .withValues(alpha: 0.5),
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ..._selectedImages.asMap().entries.map((
                MapEntry<int, File> entry,
              ) {
                final int index = entry.key;
                final File imageFile = entry.value;
                return _buildPhotoItem(context, imageFile, index);
              }),
            ],
          ),
        ),
        if (_selectedImages.isNotEmpty) ...<Widget>[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ButtonOutlined(
              text: _isUploading ? '업로드 중...' : '사진 업로드',
              onPressed: _isUploading ? null : _uploadImages,
              textColor: colors.labelNormal,
              borderColor: colors.lineNormalNormal,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _addPhotoFromGallery() async {
    if (!_canAddMorePhotos()) {
      showErrorMessage(context, _maxPhotosMessage);
      return;
    }

    await _pickImageFromGallery();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
        limit: _maxPhotoCount - _selectedImages.length,
      );

      if (pickedFiles.isNotEmpty) {
        await _addSelectedImages(
          pickedFiles.map((XFile file) => File(file.path)).toList(),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorMessage(context, '갤러리에서 이미지를 선택하는 중 오류가 발생했습니다.');
      }
    }
  }

  Future<void> _addSelectedImages(List<File> imageFiles) async {
    final List<File> validImages = <File>[];
    int duplicateCount = 0;
    int overLimitCount = 0;

    for (final File imageFile in imageFiles) {
      if (_selectedImages.length + validImages.length >= _maxPhotoCount) {
        overLimitCount++;
        continue;
      }

      final bool isDuplicate = await _isDuplicateImage(imageFile);

      if (isDuplicate) {
        duplicateCount++;
      } else {
        validImages.add(imageFile);
      }
    }

    if (validImages.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(validImages);
      });
    }

    if (mounted) {
      final List<String> messages = <String>[];

      if (validImages.isNotEmpty) {
        messages.add('${validImages.length}장의 사진이 추가되었습니다.');
      }

      if (duplicateCount > 0) {
        messages.add('$duplicateCount장은 이미 추가된 사진입니다.');
      }

      if (overLimitCount > 0) {
        messages.add('$overLimitCount장은 최대 개수 초과로 추가되지 않았습니다.');
      }

      if (messages.isNotEmpty) {
        final String combinedMessage = messages.join(' ');
        if (validImages.isNotEmpty) {
          showSuccessMessage(context, combinedMessage);
        } else {
          showErrorMessage(context, combinedMessage);
        }
      }
    }
  }

  void _removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      setState(() {
        final File removedFile = _selectedImages.removeAt(index);
        _fileHashCache.remove(removedFile.path);
      });
    }
  }

  Future<String> _calculateFileHash(File file) async {
    final String filePath = file.path;

    if (_fileHashCache.containsKey(filePath)) {
      return _fileHashCache[filePath]!;
    }

    try {
      final Stream<List<int>> fileStream = file.openRead();
      final Digest digest = await sha256.bind(fileStream).first;
      final String hash = digest.toString();

      _fileHashCache[filePath] = hash;
      return hash;
    } catch (e) {
      return filePath.hashCode.toString();
    }
  }

  Future<bool> _isDuplicateImage(File newFile) async {
    try {
      final String newFileHash = await _calculateFileHash(newFile);

      for (final File existingFile in _selectedImages) {
        final String existingFileHash = await _calculateFileHash(existingFile);
        if (newFileHash == existingFileHash) {
          return true; // 중복 발견
        }
      }

      return false; // 중복 없음
    } catch (e) {
      return false; // 오류 시 중복 없음으로 처리
    }
  }

  /// 이미지 미리보기 화면 표시
  void _showImagePreview(BuildContext context, File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder:
            (BuildContext context) => _ImagePreviewScreen(imageFile: imageFile),
      ),
    );
  }

  Widget _buildPhotoItem(BuildContext context, File imageFile, int index) {
    final SemanticColors colors = context.semanticColor;
    return Container(
      width: _containerSize,
      height: _containerSize,
      margin: const EdgeInsets.only(right: _itemSpacing),
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            top: _imageTopOffset,
            child: Container(
              width: _imageSize,
              height: _imageSize,
              decoration: BoxDecoration(
                color: colors.fillAlternative,
                border: Border.all(color: colors.lineNormalNormal, width: 1),
              ),
              child: GestureDetector(
                onTap: () {
                  _showImagePreview(context, imageFile);
                },
                child: ClipRRect(
                  child: Image.file(
                    imageFile,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                _removeImage(index);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: _deleteButtonSize,
                height: _deleteButtonSize,
                decoration: BoxDecoration(
                  color: colors.labelAlternative,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.instance.normal,
                ),
                child: Icon(
                  Icons.close,
                  size: _deleteIconSize,
                  color: colors.staticWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 이미지 미리보기 화면
class _ImagePreviewScreen extends StatelessWidget {
  const _ImagePreviewScreen({required this.imageFile});

  final File imageFile;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.staticBlack,
      appBar: AppBar(
        backgroundColor: colors.staticBlack,
        iconTheme: IconThemeData(color: colors.staticWhite),
      ),
      body: InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.file(
          imageFile,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
