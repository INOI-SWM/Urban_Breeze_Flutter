import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/workout_history/domain/entities/location_data.dart';
import 'package:ridingmate/features/workout_history/domain/entities/workout_record.dart';
import 'package:ridingmate/features/workout_history/presentation/screens/workout_detail_stat_screen.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:ridingmate/shared/design_system/widgets/button/button_outlined.dart';
import 'package:ridingmate/shared/design_system/widgets/button/custom_icon_button.dart';
import 'package:ridingmate/shared/design_system/widgets/info/info_item.dart';
import 'package:ridingmate/shared/utils/date_formatter.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.workoutIndex,
    required this.workoutRecord,
  });

  final int workoutIndex;
  final WorkoutRecord workoutRecord;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.lineNormalNormal, width: 1),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    DateFormatter.formatKorean(workoutRecord.startTime),
                    style: AppTextStyles.label2.bold.copyWith(
                      color: colors.labelAlternative,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '운동기록 ${workoutIndex + 1}',
                        style: AppTextStyles.title3.bold.copyWith(
                          color: colors.labelStrong,
                        ),
                      ),
                      CustomIconButton(
                        icon: Icons.edit_outlined,
                        onTap: () {
                          // TODO: 편집 기능 구현
                        },
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
              '${(workoutRecord.distance / 1000).toStringAsFixed(1)} km',
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
                    value:
                        '${workoutRecord.duration.inMinutes}분 ${workoutRecord.duration.inSeconds % 60}초',
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  child: InfoItem(
                    label: '평균 속도',
                    value:
                        '${(workoutRecord.distance / 1000 / (workoutRecord.duration.inMinutes / 60)).toStringAsFixed(1)} km/h',
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  child: InfoItem(
                    label: '소모 칼로리',
                    value: '${workoutRecord.calories.toStringAsFixed(0)} kcal',
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
                    value: '${workoutRecord.duration.inMinutes}분',
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
                const Expanded(
                  child: InfoItem(
                    label: '케이던스',
                    value: '--',
                    alignment: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  child: InfoItem(
                    label: '평균 심박수',
                    value: '${workoutRecord.heartRateData.first.heartRate} bpm',
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
                              const WorkoutDetailStatScreen(),
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
              child: _WorkoutDetailMapWidget(workoutRecord: workoutRecord),
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
                              const WorkoutDetailStatScreen(),
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
              style: AppTextStyles.body1.readingBold.copyWith(
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
