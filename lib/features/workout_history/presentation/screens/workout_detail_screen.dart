import 'dart:io';
import 'dart:typed_data'; // Added for Uint8List

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/workout_history/application/use_cases/update_workout_title_use_case.dart';
import 'package:ridingmate/features/workout_history/di/workout_statistics_providers.dart';
import 'package:ridingmate/features/workout_history/domain/entities/location_data.dart';
import 'package:ridingmate/features/workout_history/domain/entities/workout_record.dart';
import 'package:ridingmate/features/workout_history/presentation/screens/workout_detail_route_screen.dart';
import 'package:ridingmate/features/workout_history/presentation/screens/workout_detail_stat_screen.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_outlined.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:ridingmate/shared/design_system/widgets/info/info_item.dart';
import 'package:ridingmate/shared/design_system/widgets/modal/modal_show.dart';
import 'package:ridingmate/shared/design_system/widgets/text_field/inline_edit_text_field.dart';
import 'package:ridingmate/shared/map/common_map_widgets.dart';
import 'package:ridingmate/shared/map/map_constants.dart';
import 'package:ridingmate/shared/mixins/error_display_mixin.dart';
import 'package:ridingmate/shared/utils/date_formatter.dart';
import 'package:ridingmate/shared/utils/workout_formatter.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workoutIndex,
    required this.workoutRecord,
  });

  final int workoutIndex;
  final WorkoutRecord workoutRecord;

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen>
    with ErrorDisplayMixin {
  // 상수 정의
  static const int _maxTitleLength = 60;
  static const int _maxPhotoCount = 30;
  static const String _emptyTitleMessage = '제목은 비어있을 수 없습니다';
  static const String _titleSavedMessage = '제목이 저장되었습니다';
  static const String _unknownErrorMessage = '알 수 없는 오류가 발생했습니다';
  static const String _unsavedChangesMessage = '저장되지 않는 내용은 모두 사라집니다.';
  static const String _maxPhotosMessage = '최대 30장까지만 추가할 수 있습니다.';

  bool _isEditingTitle = false;
  late String _workoutTitle;

  // 사진 관련 상태 변수
  final List<File> _selectedImages = <File>[];
  final ImagePicker _imagePicker = ImagePicker();

  // 파일 내용 기반 중복 체크 메서드
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
      // 오류 발생 시 중복이 아닌 것으로 처리
      return false;
    }
  }

  // 두 바이트 리스트가 동일한지 비교
  bool _areByteListsEqual(Uint8List list1, Uint8List list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    _workoutTitle = '운동기록 ${widget.workoutIndex + 1}';
  }

  bool _isValidTitle(String title) {
    return title.trim().isNotEmpty;
  }

  bool _isTitleChanged(String newTitle) {
    return newTitle.trim() != _workoutTitle.trim();
  }

  // 사진 관련 검증 메서드
  bool _canAddMorePhotos() {
    return _selectedImages.length < _maxPhotoCount;
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
    await useCase.execute(workoutId: widget.workoutRecord.id, title: newTitle);
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

  // 사진 관련 메서드들
  Future<void> _addPhotoFromGallery() async {
    if (!_canAddMorePhotos()) {
      showErrorMessage(context, _maxPhotosMessage);
      return;
    }

    // 바로 갤러리로 이동
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
      // 최대 개수 확인
      if (_selectedImages.length + validImages.length >= _maxPhotoCount) {
        overLimitCount++;
        continue;
      }

      // 파일 내용 기반 중복 확인
      final bool isDuplicate = await _isDuplicateImage(imageFile);

      if (isDuplicate) {
        duplicateCount++;
      } else {
        validImages.add(imageFile);
      }
    }

    // 유효한 이미지들 추가
    if (validImages.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(validImages);
      });
    }

    // 사용자 피드백 제공
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

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    return Scaffold(
      backgroundColor: colors.backgroundNormalNormal,
      appBar: CustomAppBar(
        leading: CustomIconButton(
          icon: Icons.arrow_back_ios_new,
          onTap: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          CustomIconButton(
            icon: Icons.more_vert,
            onTap: () {
              // TODO: 더보기 메뉴 구현
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colors.lineNormalNormal,
                            width: 1,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            DateFormatter.formatKorean(
                              widget.workoutRecord.startTime,
                            ),
                            style: AppTextStyles.label2.bold.copyWith(
                              color: colors.labelAlternative,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child:
                                    _isEditingTitle
                                        ? InlineEditTextField(
                                          initialText: _workoutTitle,
                                          onSaved: (String newTitle) {
                                            _showSaveConfirmationDialog(
                                              newTitle,
                                            );
                                          },
                                          onSubmitted: (String newTitle) {
                                            _saveTitle(newTitle);
                                          },
                                          textStyle: AppTextStyles.title3.bold
                                              .copyWith(
                                                color: colors.labelStrong,
                                              ),
                                          maxLength: _maxTitleLength,
                                        )
                                        : Text(
                                          _workoutTitle,
                                          style: AppTextStyles.title3.bold
                                              .copyWith(
                                                color: colors.labelStrong,
                                              ),
                                        ),
                              ),
                              if (!_isEditingTitle)
                                CustomIconButton(
                                  icon: Icons.edit_outlined,
                                  onTap: _startEditing,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '이동 거리',
                      style: AppTextStyles.label1.normalBold.copyWith(
                        color: colors.labelAlternative,
                      ),
                    ),
                    Text(
                      WorkoutFormatter.toKmText(widget.workoutRecord.distance),
                      style: AppTextStyles.display1.bold.copyWith(
                        color: colors.labelStrong,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InfoItem(
                            label: '운동 시간',
                            value: WorkoutFormatter.toDurationText(
                              widget.workoutRecord.duration,
                            ),
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Expanded(
                          child: InfoItem(
                            label: '평균 속도',
                            value: WorkoutFormatter.toSpeedText(
                              widget.workoutRecord.distance,
                              widget.workoutRecord.duration,
                            ),
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Expanded(
                          child: InfoItem(
                            label: '소모 칼로리',
                            value: WorkoutFormatter.toCaloriesText(
                              widget.workoutRecord.calories,
                            ),
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    //TODO: api 개발 후 데이터 변경
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InfoItem(
                            label: '전체 시간',
                            value: WorkoutFormatter.toDurationText(
                              widget.workoutRecord.duration,
                            ),
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Expanded(
                          child: InfoItem(
                            label: '케이던스',
                            value: WorkoutFormatter.toCadenceText(
                              null,
                            ), // 데이터 없음
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Expanded(
                          child: InfoItem(
                            label: '평균 심박수',
                            value: WorkoutFormatter.toHeartRateText(
                              widget.workoutRecord.heartRateData.first.heartRate
                                  .toDouble(),
                            ),
                            alignment: CrossAxisAlignment.start,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ButtonOutlined(
                        text: '상세 정보',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder:
                                  (BuildContext context) =>
                                      WorkoutDetailStatScreen(
                                        workoutIndex: widget.workoutIndex,
                                        workoutRecord: widget.workoutRecord,
                                      ),
                            ),
                          );
                        },
                        textColor: colors.labelNormal,
                        borderColor: colors.lineNormalNormal,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: _WorkoutDetailMapWidget(
                        workoutRecord: widget.workoutRecord,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ButtonOutlined(
                        text: '상세 경로',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder:
                                  (BuildContext context) =>
                                      WorkoutDetailRouteScreen(
                                        workoutRecord: widget.workoutRecord,
                                      ),
                            ),
                          );
                        },
                        textColor: colors.labelNormal,
                        borderColor: colors.lineNormalNormal,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                  ],
                ),
              ),
              // 사진 섹션 - 전체 너비 사용
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    // 사진 추가 버튼
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
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
                    // 선택된 사진들 동적 생성
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
              const SizedBox(height: 50), // 빈 공간 추가
            ],
          ),
        ),
      ),
    );
  }

  /// 사진 아이템 위젯 생성 TODO: stateless widget 으로 변경
  Widget _buildPhotoItem(BuildContext context, File imageFile, int index) {
    final SemanticColors colors = context.semanticColor;
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: colors.fillAlternative,
        border: Border.all(color: colors.lineNormalNormal, width: 1),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          // 실제 PNG 이미지 표시
          ClipRRect(
            child: Image.file(
              imageFile,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // 삭제 버튼
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: () {
                _removeImage(index);
              },
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors.labelAlternative,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//TODO: 추후 api 연결 시 폴리곤 띄우기 방식 변경, bbox로 지도 크기 조정
class _WorkoutDetailMapWidget extends StatelessWidget {
  const _WorkoutDetailMapWidget({required this.workoutRecord});

  final WorkoutRecord workoutRecord;

  static const LatLng _defaultCenter = MapConstants.seoulCityHall;
  static const double _defaultZoom = MapConstants.defaultZoom;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;

    final List<LatLng> routePoints = _convertLocationDataToLatLng(
      workoutRecord.locationData,
    );

    // LatLngBounds를 사용한 카메라 설정
    final CameraFit? cameraFit = _calculateCameraFit(routePoints);

    return FlutterMap(
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: _defaultZoom,
        initialCameraFit: cameraFit,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
      ),
      children: <Widget>[
        CommonMapWidgets.createTileLayer(),
        // 운동 경로 폴리라인
        if (routePoints.isNotEmpty)
          PolylineLayer<LatLng>(
            polylines: <Polyline<LatLng>>[
              Polyline<LatLng>(
                points: routePoints,
                color: colors.primaryNormal,
                strokeWidth: MapConstants.polylineStrokeWidth,
              ),
            ],
          ),
        CommonMapWidgets.createAttributionWidget(),
      ],
    );
  }

  /// WorkoutRecord의 locationData를 LatLng 포인트들로 변환 TODO : 추후 mapper에서 변환
  List<LatLng> _convertLocationDataToLatLng(List<LocationData> locationData) {
    return locationData
        .map((LocationData data) => LatLng(data.latitude, data.longitude))
        .toList();
  }

  CameraFit? _calculateCameraFit(List<LatLng> routePoints) {
    if (routePoints.isEmpty) {
      return null;
    }

    final LatLngBounds bounds = _calculateLatLngBounds(routePoints);
    return CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(20));
  }

  LatLngBounds _calculateLatLngBounds(List<LatLng> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      LatLng(minLat, minLng), // southwest
      LatLng(maxLat, maxLng), // northeast
    );
  }
}
