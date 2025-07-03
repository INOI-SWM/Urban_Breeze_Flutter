import 'package:flutter/material.dart';
import 'package:ridingmate/features/workout_history/domain/entities/distance_data.dart';
import 'package:ridingmate/features/workout_history/domain/entities/heart_rate_data.dart';

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
      // Repository를 통해 모든 데이터가 포함된 자전거 운동 데이터 가져오기
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('운동 기록'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 권한 요청 버튼
            ElevatedButton.icon(
              onPressed: _requestPermissions,
              icon: const Icon(Icons.security),
              label: const Text('권한 요청'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 8),

            // 테스트 버튼
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGetCyclingWorkouts,
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Icon(Icons.directions_bike),
              label: Text(_isLoading ? '로딩 중...' : '자전거 운동 데이터 가져오기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 16),

            // 결과 표시
            Expanded(child: _buildResultWidget()),
          ],
        ),
      ),
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
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Icon(Icons.info_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                '운동 데이터가 없습니다',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '먼저 권한을 요청하고 데이터를 불러오세요',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.directions_bike, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '자전거 운동 (${_workouts.length}개)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_workouts.isNotEmpty) ...<Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: _workouts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final WorkoutRecord workout = _workouts[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: const Icon(Icons.fitness_center),
                        title: Text('운동 ${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '시작: ${workout.startTime.toString().substring(0, 16)}',
                            ),
                            Text('소요시간: ${workout.duration.inMinutes}분'),
                            Text(
                              '거리: ${(workout.distance / 1000).toStringAsFixed(2)}km',
                            ),
                            Text(
                              '칼로리: ${workout.calories.toStringAsFixed(1)}kcal',
                            ),
                          ],
                        ),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  '📊 상세 데이터',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '❤️ 심박수 데이터: ${workout.heartRateData.length}개',
                                ),
                                if (workout
                                    .heartRateData
                                    .isNotEmpty) ...<Widget>[
                                  Text(
                                    '   최고: ${workout.heartRateData.map((HeartRateData e) => e.heartRate).reduce((int a, int b) => a > b ? a : b)}bpm',
                                  ),
                                  Text(
                                    '   평균: ${(workout.heartRateData.map((HeartRateData e) => e.heartRate).reduce((int a, int b) => a + b) / workout.heartRateData.length).round()}bpm',
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  '📏 거리 데이터: ${workout.distanceData.length}개',
                                ),
                                if (workout
                                    .distanceData
                                    .isNotEmpty) ...<Widget>[
                                  Text(
                                    '   총 거리: ${(workout.distanceData.map((DistanceData e) => e.distance).reduce((double a, double b) => a + b) / 1000).toStringAsFixed(2)}km',
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  '🗺️ GPS 경로: ${workout.locationData.isNotEmpty ? '${workout.locationData.length}개 포인트' : '없음'}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else ...<Widget>[
              const Center(
                child: Text(
                  '데이터를 불러오는 중...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
