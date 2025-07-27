import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  bool _isEditingTitle = false;
  late String _workoutTitle;

  @override
  void initState() {
    super.initState();
    _workoutTitle = '운동기록 ${widget.workoutIndex + 1}';
  }

  void _startEditing() {
    setState(() {
      _isEditingTitle = true;
    });
  }

  Future<void> _saveTitle(String newTitle) async {
    if (newTitle.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('제목은 비어있을 수 없습니다')));
      }
      return;
    }

    try {
      final UpdateWorkoutTitleUseCase useCase = ref.read(
        updateWorkoutTitleUseCaseProvider,
      );

      await useCase.execute(
        workoutId: widget.workoutRecord.id,
        title: newTitle,
      );

      setState(() {
        _workoutTitle = newTitle;
        _isEditingTitle = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('제목이 저장되었습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('알 수 없는 오류가 발생했습니다: ${e.toString()}')),
        );
      }
    }
  }

  void _showSaveConfirmationDialog(String newTitle) {
    if (newTitle.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('제목은 비어있을 수 없습니다')));
      }
      return;
    }

    ModalShow.show(
      context: context,
      content: Text(
        '저장되지 않는 내용은 모두 사라집니다.',
        textAlign: TextAlign.center,
        style: AppTextStyles.label1.readingBold,
      ),
      primaryButtonText: '저장',
      secondaryButtonText: '취소',
      onPrimaryButtonPressed: () {
        _saveTitle(newTitle);
      },
      onSecondaryButtonPressed: () {
        setState(() {
          _isEditingTitle = false;
        });
      },
    );
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
                                          maxLength: 60,
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
                                      const WorkoutDetailRouteScreen(),
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
                      '최대 30장의 사진을 추가할 수 있습니다.',
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
                          onTap: () {
                            // TODO: 사진 추가 기능 구현
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 24,
                                color: colors.labelAlternative,
                              ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 예시 사진들
                    _buildPhotoItem(context, '1'),
                    _buildPhotoItem(context, '2'),
                    _buildPhotoItem(context, '3'),
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
  Widget _buildPhotoItem(BuildContext context, String label) {
    const String imagePath = 'assets/images/png/thumbnail_r1_1.png';
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
            child: Image.asset(
              imagePath,
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
                // TODO: 사진 삭제 기능 구현
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

  static const LatLng _defaultCenter = LatLng(37.5665, 126.9780);
  static const double _defaultZoom = 13.0;

  @override
  Widget build(BuildContext context) {
    final SemanticColors colors = context.semanticColor;
    final String baseUrl = dotenv.env['GEOAPIFY_BASE_URL'] ?? 'fallback_url';
    final String apiKey = dotenv.env['GEOAPIFY_API_KEY'] ?? 'fallback_key';
    final String fullUrlTemplate = '$baseUrl?&apiKey=$apiKey';

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
        TileLayer(
          urlTemplate: fullUrlTemplate,
          userAgentPackageName: 'com.example.ridingmate',
          subdomains: const <String>['a', 'b', 'c'],
        ),
        // 운동 경로 폴리라인
        if (routePoints.isNotEmpty)
          PolylineLayer<LatLng>(
            polylines: <Polyline<LatLng>>[
              Polyline<LatLng>(
                points: routePoints,
                color: colors.primaryNormal,
                strokeWidth: 4.0,
              ),
            ],
          ),
        RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          showFlutterMapAttribution: false,
          attributions: <SourceAttribution>[
            TextSourceAttribution(
              'Powered by Geoapify | © OpenStreetMap contributors',
              textStyle: AppTextStyles.caption2.regular,
            ),
          ],
        ),
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
