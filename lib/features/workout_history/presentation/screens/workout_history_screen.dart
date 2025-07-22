import 'package:flutter/material.dart';
import 'package:ridingmate/core/extensions/theme_extensions.dart';
import 'package:ridingmate/features/workout_history/presentation/screens/workout_detail_screen.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';
import 'package:ridingmate/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:ridingmate/shared/design_system/widgets/card/card_list.dart';
import 'package:ridingmate/shared/design_system/widgets/thumbnail/thumbnail.dart';

import '../../data/repositories/apple_health_kit_sync_repository_impl.dart';
import '../../domain/entities/workout_record.dart';

//TODO : 추후 api 개발 시 에러 처리 추가
class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  bool _isLoading = false;
  List<WorkoutRecord> _workouts = <WorkoutRecord>[];

  final AppleHealthKitSyncRepositoryImpl _repository =
      AppleHealthKitSyncRepositoryImpl();

  Future<void> _testGetCyclingWorkouts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // todo : 추후 서버 API 호출로 변경
      final List<WorkoutRecord> workouts = await _repository
          .fetchCyclingWorkoutsFromHealthKit(
            startDate: DateTime.now().subtract(const Duration(days: 30)),
            endDate: DateTime.now(),
          );

      setState(() {
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await _repository.requestPermissions();
    } catch (e) {
      // TODO : 권한 요청 실패 시 무시
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // TODO: 개발 완료 후 삭제 예정
        _buildTestButtons(),

        const SizedBox(height: 16),

        // 결과 표시
        Expanded(child: _buildResultWidget()),
      ],
    );
  }

  // TODO: 개발 완료 후 이 메서드 전체 삭제 예정
  Widget _buildTestButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _requestPermissions,
            icon: const Icon(Icons.security),
            label: const Text('권한 요청'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _testGetCyclingWorkouts,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.directions_bike),
            label: Text(_isLoading ? '로딩 중...' : ' 데이터 가져오기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultWidget() {
    final SemanticColors colors = context.semanticColor;
    if (_workouts.isEmpty && !_isLoading) {
      return Column(
        children: <Widget>[
          Icon(Icons.info_outline, size: 48, color: colors.labelAlternative),
          const SizedBox(height: 8),
          Text('운동 데이터가 없습니다', style: AppTextStyles.body2.normalBold),
          const SizedBox(height: 4),
          Text(
            '먼저 권한을 요청하고 데이터를 불러오세요',
            style: AppTextStyles.label2.medium.copyWith(
              color: colors.labelAlternative,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (_workouts.isNotEmpty) ...<Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _workouts.length,
              itemBuilder: (BuildContext context, int index) {
                final WorkoutRecord workout = _workouts[index];
                // TODO : 서버 저장 양식에 따라 데이터 파싱 변경
                debugPrint('workout: $workout');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CardList(
                    thumbnailPath: 'assets/images/png/thumbnail_r3_2.png',
                    sourceType: ThumbnailSourceType.asset,
                    title: '운동 ${index + 1}',
                    createDate: workout.startTime.toString().substring(0, 16),
                    badges: <BadgeData>[
                      BadgeData(
                        text:
                            '${(workout.distance / 1000).toStringAsFixed(1)}km',
                        icon: Icons.route,
                      ),
                      BadgeData(
                        text: '${workout.duration.inMinutes}분',
                        icon: Icons.access_time,
                      ),
                    ],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder:
                              (BuildContext context) => WorkoutDetailScreen(
                                workoutRecord: workout,
                                workoutIndex: index,
                              ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ] else ...<Widget>[
          Center(
            child: Text(
              '데이터를 불러오는 중...',
              style: AppTextStyles.label2.medium.copyWith(
                color: colors.labelAlternative,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
