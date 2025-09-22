import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/di/workout_history_providers.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/activity_image.dart';
import 'package:urban_breeze/shared/design_system/tokens/decorations/app_shadows.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class WorkoutPhotoGalleryWidget extends ConsumerStatefulWidget {
  const WorkoutPhotoGalleryWidget({
    super.key,
    required this.activityId,
    this.initialImages = const <ActivityImage>[],
  });

  final String activityId;
  final List<ActivityImage> initialImages;

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

  final List<File> _selectedImages = <File>[]; // 갤러리에서 선택한 이미지들
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  // 모든 이미지 (초기 이미지 + 업로드된 이미지)
  List<ActivityImage> _allImages = <ActivityImage>[];

  @override
  void initState() {
    super.initState();
    // 초기 이미지들을 전체 이미지 리스트에 추가
    _allImages = List<ActivityImage>.from(widget.initialImages);
  }

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
      final AppResult<List<ActivityImage>> result = await ref
          .read(uploadWorkoutImagesUseCaseProvider)
          .execute(activityId: widget.activityId, imageFiles: _selectedImages);

      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        if (result.isSuccess) {
          final List<ActivityImage> uploadedImages = result.dataOrNull!;
          showSuccessMessage(
            context,
            '${uploadedImages.length}장의 사진이 성공적으로 업로드되었습니다!',
          );

          // 업로드된 이미지들을 전체 이미지 리스트에 추가
          setState(() {
            _allImages.addAll(uploadedImages);
            _selectedImages.clear(); // 갤러리에서 선택한 이미지들은 초기화
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
          _isUploading ? '업로드 중... 잠시만 기다려주세요' : '${_allImages.length}장',
          style: AppTextStyles.label1.readingBold.copyWith(
            color:
                _isUploading ? colors.primaryNormal : colors.labelAlternative,
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
                            child:
                                _isUploading
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  colors.primaryNormal,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '업로드',
                                          style: AppTextStyles.caption1.regular
                                              .copyWith(
                                                color: colors.labelAlternative,
                                              ),
                                        ),
                                      ],
                                    )
                                    : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 24,
                                          color:
                                              _canAddMorePhotos()
                                                  ? colors.labelAlternative
                                                  : colors.labelAlternative
                                                      .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 4),
                                        if (!_canAddMorePhotos())
                                          Text(
                                            '최대',
                                            style: AppTextStyles
                                                .caption1
                                                .regular
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
              // 모든 업로드된 이미지들 표시 (서버 URL로 표시)
              ..._allImages.asMap().entries.map((
                MapEntry<int, ActivityImage> entry,
              ) {
                final int index = entry.key;
                final ActivityImage image = entry.value;
                return _buildImageItem(
                  context,
                  image,
                  index,
                  true,
                ); // true = 서버 이미지
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
    int overLimitCount = 0;

    for (final File imageFile in imageFiles) {
      if (_selectedImages.length + validImages.length >= _maxPhotoCount) {
        overLimitCount++;
        continue;
      }

      validImages.add(imageFile);
    }

    if (validImages.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(validImages);
      });

      // 이미지가 추가되면 바로 업로드 시작
      await _uploadImages();
    }

    if (mounted && overLimitCount > 0) {
      showErrorMessage(context, '$overLimitCount장은 최대 개수 초과로 추가되지 않았습니다.');
    }
  }

  void _removeImage(int index, bool isServerImage) {
    // TODO: 서버 이미지 삭제 API 호출 구현
    print('이미지 삭제 요청 - index: $index');
    // setState(() {
    //   _allImages.removeAt(index);
    // });
  }

  /// 이미지 미리보기 화면 표시
  void _showImagePreview(BuildContext context, ActivityImage image) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => _ImagePreviewScreen(image: image),
      ),
    );
  }

  /// 이미지 아이템 (모든 이미지에 삭제 버튼 있음)
  Widget _buildImageItem(
    BuildContext context,
    ActivityImage image,
    int index,
    bool isServerImage,
  ) {
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
                  _showImagePreview(context, image);
                },
                child: ClipRRect(
                  child: Image.network(
                    image.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? loadingProgress,
                    ) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colors.primaryNormal,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return Container(
                        color: colors.fillNormal,
                        child: Icon(
                          Icons.broken_image,
                          color: colors.labelAlternative,
                          size: 32,
                        ),
                      );
                    },
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
                _removeImage(index, isServerImage);
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
  const _ImagePreviewScreen({required this.image});

  final ActivityImage image;

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
        child: Image.network(
          image.imageUrl,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.staticWhite),
              ),
            );
          },
          errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.broken_image, color: colors.staticWhite, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    '이미지를 불러올 수 없습니다',
                    style: AppTextStyles.body1.normalMedium.copyWith(
                      color: colors.staticWhite,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
