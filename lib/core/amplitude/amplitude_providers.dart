import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'amplitude_service.dart';

/// Amplitude 서비스 프로바이더
/// 싱글톤 인스턴스를 제공
final Provider<AmplitudeService> amplitudeServiceProvider =
    Provider<AmplitudeService>(
      (Ref<AmplitudeService> ref) => AmplitudeService.instance,
    );

/// Amplitude 초기화 상태 프로바이더
final Provider<bool> amplitudeInitializedProvider = Provider<bool>((
  Ref<bool> ref,
) {
  final AmplitudeService amplitudeService = ref.watch(amplitudeServiceProvider);
  return amplitudeService.isInitialized;
});
