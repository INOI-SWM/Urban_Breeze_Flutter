import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/amplitude/amplitude_analytics.dart';
import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/core/services/universal_link_service.dart';
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

  /// Universal Link 진입 추적 (Amplitude만 사용)
  Future<void> _trackUniversalLinkEntry(String routeId) async {
    try {
      // Amplitude에 이벤트 전송
      await AmplitudeAnalytics.logEvent(
        'universal_link_received',
        properties: <String, dynamic>{
          'route_id': routeId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Universal Link 추적 실패해도 메인 기능은 계속 진행
    }
  }

  static void initialize(WidgetRef ref, BuildContext context) {
    try {
      UniversalLinkService().routeShareStream.listen(
        (RouteShareCallback callback) {
          if (!context.mounted) return;
          _instance._handleRouteShare(ref, context, callback);
        },
        onError: (Object error) {
          // Universal Link 스트림 오류 처리
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
    if (_isProcessing) {
      return;
    }

    _isProcessing = true;

    try {
      // ID 유효성 검사
      if (!callback.isValid) {
        // 유효하지 않은 링크 추적
        AmplitudeAnalytics.logEvent(
          'universal_link_invalid',
          properties: <String, dynamic>{
            'type': 'route',
            'reason': 'empty_route_id',
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        if (!context.mounted) return;
        showErrorMessage(context, '유효하지 않은 공유 링크입니다');
        _isProcessing = false;
        return;
      }

      // Universal Link 진입 추적 (로그인 상태와 관계없이)
      await _trackUniversalLinkEntry(callback.routeId);

      // 로그인 상태 확인
      final bool isLoggedIn = ref.read(isLoggedInProvider);

      if (!isLoggedIn) {
        // 로그인 필요 로깅
        AmplitudeAnalytics.logEvent(
          'route_share_login_required',
          properties: <String, dynamic>{
            'route_id': callback.routeId,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        // 로그인하지 않은 경우 안내 메시지 표시
        if (!context.mounted) return;
        showErrorMessage(context, '경로를 저장하려면 로그인이 필요합니다');
        _isProcessing = false;
        return;
      }
    } catch (e) {
      if (!context.mounted) return;
      showErrorMessage(context, '링크 처리 중 오류가 발생했습니다');
      _isProcessing = false;
      return;
    }

    try {
      // 경로 저장 시도
      final SaveSharedRouteUseCase saveSharedRouteUseCase = ref.read(
        saveSharedRouteUseCaseProvider,
      );

      final AppResult<void> result = await saveSharedRouteUseCase.execute(
        callback.routeId,
      );

      if (!context.mounted) return;

      if (result.isSuccess) {
        // 경로 저장 성공 로깅
        AmplitudeAnalytics.logEvent(
          'route_share_success',
          properties: <String, dynamic>{
            'route_id': callback.routeId,
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        // 성공 메시지 표시
        showSuccessMessage(context, '경로 저장에 성공하였습니다');

        // 경로 세부사항 화면으로 이동
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder:
                (BuildContext context) =>
                    MyRouteDetailScreen(routeId: callback.routeId),
          ),
        );
      } else {
        _handleRouteShareError(
          context,
          result as AppFailure<void>,
          callback.routeId,
        );
      }
    } catch (e) {
      // 예상치 못한 에러 로깅
      AmplitudeAnalytics.logEvent(
        'route_share_unexpected_error',
        properties: <String, dynamic>{
          'route_id': callback.routeId,
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (!context.mounted) return;
      showErrorMessage(context, '경로 저장 중 오류가 발생했습니다');
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
      AmplitudeAnalytics.logEvent(
        'route_share_failed',
        properties: <String, dynamic>{
          'route_id': routeId,
          'error': 'already_added',
          'error_code': '409',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      showErrorMessage(context, '이미 저장된 경로입니다');
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder:
              (BuildContext context) => MyRouteDetailScreen(routeId: routeId),
        ),
      );
    } else {
      // 404, 403, 기타 모든 에러 → "경로를 찾을 수 없습니다"
      AmplitudeAnalytics.logEvent(
        'route_share_failed',
        properties: <String, dynamic>{
          'route_id': routeId,
          'error': exception.runtimeType.toString(),
          'error_message': exception.message,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      showErrorMessage(context, '경로를 찾을 수 없습니다');
    }
  }
}
