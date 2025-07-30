import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/mixins/error_display_mixin.dart';

class WorkoutPhotoGalleryWidget extends StatefulWidget {
  const WorkoutPhotoGalleryWidget({super.key});

  @override
  State<WorkoutPhotoGalleryWidget> createState() =>
      _WorkoutPhotoGalleryWidgetState();
}

class _WorkoutPhotoGalleryWidgetState extends State<WorkoutPhotoGalleryWidget>
    with ErrorDisplayMixin {
  static const int _maxPhotoCount = 30;
  static const String _maxPhotosMessage = '최대 30장까지만 추가할 수 있습니다.';

  final List<File> _selectedImages = <File>[];
  final ImagePicker _imagePicker = ImagePicker();

  bool _canAddMorePhotos() {
    return _selectedImages.length < _maxPhotoCount;
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
        const SizedBox(height: 8),
        Text(
          '${_selectedImages.length}/$_maxPhotoCount장 (최대 30장까지 추가 가능)',
          style: AppTextStyles.label1.readingBold.copyWith(
            color: colors.labelAlternative,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 112,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                width: 112,
                height: 112,
                margin: const EdgeInsets.only(right: 4),
                color: Colors.transparent,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 12,
                      child: Container(
                        width: 100,
                        height: 100,
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
        limit:
            _canAddMorePhotos() ? (_maxPhotoCount - _selectedImages.length) : 1,
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
        _selectedImages.removeAt(index);
      });
    }
  }

  Future<bool> _isDuplicateImage(File newFile) async {
    try {
      final Uint8List newFileBytes = await newFile.readAsBytes();

      for (final File existingFile in _selectedImages) {
        // 파일 크기 먼저 비교 (성능 최적화)
        final int newFileSize = newFileBytes.length;
        final int existingFileSize = await existingFile.length();

        if (newFileSize == existingFileSize) {
          // 크기가 같으면 바이트 데이터 비교
          final Uint8List existingFileBytes = await existingFile.readAsBytes();
          if (_areByteListsEqual(newFileBytes, existingFileBytes)) {
            return true; // 중복 발견
          }
        }
      }

      return false; // 중복 없음
    } catch (e) {
      return false;
    }
  }

  bool _areByteListsEqual(Uint8List list1, Uint8List list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }

    return true;
  }

  Widget _buildPhotoItem(BuildContext context, File imageFile, int index) {
    final SemanticColors colors = context.semanticColor;
    return Container(
      width: 112,
      height: 112,
      margin: const EdgeInsets.only(right: 4),
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            top: 12,
            child: Container(
              width: 100, // 원본 크기 유지
              height: 100, // 원본 크기 유지
              decoration: BoxDecoration(
                color: colors.fillAlternative,
                border: Border.all(color: colors.lineNormalNormal, width: 1),
              ),
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
          // 삭제 버튼 - 이미지 Container 밖으로 나가 보이지만 실제로는 바깥 Container 안에 있음
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                _removeImage(index);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colors.labelAlternative,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 1,
                      offset: const Offset(0, 0.5),
                    ),
                  ],
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
