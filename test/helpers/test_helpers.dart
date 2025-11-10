import 'package:flutter_test/flutter_test.dart';

/// 비동기 작업 대기를 위한 헬퍼 함수
Future<void> pumpEventQueue({int times = 20}) async {
  for (int i = 0; i < times; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// 특정 시간만큼 대기하는 헬퍼 함수 (테스트용)
Future<void> waitFor(Duration duration) async {
  await Future<void>.delayed(duration);
}
