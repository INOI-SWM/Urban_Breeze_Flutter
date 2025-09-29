import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/core/services/deep_link_service.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/my_route/application/usecases/save_shared_route_usecase.dart';
import 'package:urban_breeze/features/my_route/di/my_route_providers.dart';
import 'package:urban_breeze/features/my_route/domain/exceptions/route_share_exceptions.dart';
import 'package:urban_breeze/features/my_route/presentation/screens/my_route_detail_screen.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class RouteShareHandler with ErrorDisplayMixin {
  factory RouteShareHandler() => _instance;
  RouteShareHandler._internal();
  static final RouteShareHandler _instance = RouteShareHandler._internal();

  // 중복 처리 방지를 위한 플래그
  bool _isProcessing = false;

  /// 딥링크 진입 추적 (Amplitude만 사용)
  Future<void> _trackDeepLinkEntry(String routeId) async {
    try {
      // Amplitude에 이벤트 전송
      await AmplitudeAnalytics.logEvent(
        'deep_link_received',
        properties: <String, dynamic>{
          'route_id': routeId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // 딥링크 추적 실패해도 메인 기능은 계속 진행
    }
  }

  static void initialize(WidgetRef ref, BuildContext context) {
    try {
      DeepLinkService().routeShareStream.listen(
        (RouteShareCallback callback) {
          if (!context.mounted) return;
          _instance._handleRouteShare(ref, context, callback);
        },
        onError: (Object error) {
          // 딥링크 스트림 오류 처리
        },
      );
    } catch (e) {
      // 초기화 오류 처리
    }
  }

  Future<void> _handleRouteShare(
    WidgetRef ref,
    BuildContext context,
    RouteShareCallback callback,
  ) async {
    // 중복 처리 방지
    if (_isProcessing) return;

    _isProcessing = true;

    try {
      if (!callback.isValid) return;

      // 딥링크 진입 추적 (로그인 상태와 관계없이)
      await _trackDeepLinkEntry(callback.routeId);

      // 로그인 상태 확인
      final bool isLoggedIn = ref.read(isLoggedInProvider);

      if (!isLoggedIn) {
        // 로그인하지 않은 경우 딥링크 무시
        _isProcessing = false;
        return;
      }
    } catch (e) {
      _isProcessing = false;
      return;
    }

    try {
      final SaveSharedRouteUseCase saveSharedRouteUseCase = ref.read(
        saveSharedRouteUseCaseProvider,
      );

      final AppResult<void> result = await saveSharedRouteUseCase.execute(
        callback.routeId,
      );

      if (!context.mounted) return;

      if (result.isSuccess) {
        // 성공 메시지 표시
        showSuccessMessage(context, '공유된 경로가 나의 경로에 성공적으로 추가되었습니다');

        // 경로 세부사항 화면으로 이동
        Navigator.of(context)
            .push(
              MaterialPageRoute<void>(
                builder:
                    (BuildContext context) =>
                        MyRouteDetailScreen(routeId: callback.routeId),
              ),
            )
            .then((_) {
              // 경로 세부사항에서 돌아올 때 리스트 새로고침을 위한 이벤트 발생
              // MyRouteScreen이 활성화되어 있다면 자동으로 새로고침됨
            });
      } else {
        _handleRouteShareError(
          context,
          result as AppFailure<void>,
          callback.routeId,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      showErrorMessage(context, '공유된 경로 저장 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      _isProcessing = false;
    }
  }

  /// 에러코드별 다른 동작 처리
  void _handleRouteShareError(
    BuildContext context,
    AppFailure<void> failure,
    String routeId,
  ) {
    final BaseDomainException exception = failure.exception;

    if (exception is RouteAlreadyAddedException) {
      // 409: 이미 추가된 경로 - Detail 화면으로 이동하고 메시지 표시
      showErrorMessage(context, exception.message);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder:
              (BuildContext context) => MyRouteDetailScreen(routeId: routeId),
        ),
      );
    } else if (exception is RouteNotFoundException ||
        exception is RouteAccessDeniedException) {
      // 404, 403: 경로를 찾을 수 없음 또는 접근 거부 - My Route List에서만 메시지 표시
      showErrorMessage(context, exception.message);
    } else {
      // 기타 에러 - 일반적인 에러 처리
      showErrorFromAppResult(context, failure);
    }
  }
}
