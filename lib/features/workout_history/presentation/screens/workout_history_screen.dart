import 'package:flutter/material.dart';
import 'package:ridingmate/shared/design_system/widgets/card/card_list.dart';
import 'package:ridingmate/shared/design_system/widgets/thumbnail/thumbnail.dart';

import '../../data/repositories/apple_health_kit_sync_repository_impl.dart';
import '../../domain/entities/workout_record.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  bool _isLoading = false;
  List<WorkoutRecord> _workouts = <WorkoutRecord>[];
  String? _errorMessage;
  final AppleHealthKitSyncRepositoryImpl _repository =
      AppleHealthKitSyncRepositoryImpl();

  Future<void> _testGetCyclingWorkouts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    try {
      await _repository.requestPermissions();
    } catch (e) {
      // 권한 요청 실패 시 무시
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
    if (_errorMessage != null) {
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.error, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '오류 발생',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade600),
              ),
            ],
          ),
        ),
      );
    }

    if (_workouts.isEmpty && !_isLoading) {
      return const Column(
        children: <Widget>[
          Icon(Icons.info_outline, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            '운동 데이터가 없습니다',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text('먼저 권한을 요청하고 데이터를 불러오세요', style: TextStyle(color: Colors.grey)),
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
                            '${(workout.distance / 1000000).toStringAsFixed(1)}km',
                        icon: Icons.route,
                      ),
                      BadgeData(
                        text: '${workout.duration.inMinutes}분',
                        icon: Icons.access_time,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ] else ...<Widget>[
          const Center(
            child: Text('데이터를 불러오는 중...', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ],
    );
  }
}
