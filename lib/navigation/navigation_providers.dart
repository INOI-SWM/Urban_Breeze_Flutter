import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/features/workout_history/presentation/pages/workout_history_page.dart';

// 하단 네비게이션 현재 인덱스
final StateProvider<int> bottomNavIndexProvider = StateProvider<int>(
  (Ref ref) => 0,
);

// 기록 화면의 선택된 탭
final StateProvider<WorkoutHistoryTab> workoutHistoryTabProvider =
    StateProvider<WorkoutHistoryTab>((Ref ref) => WorkoutHistoryTab.statistics);
