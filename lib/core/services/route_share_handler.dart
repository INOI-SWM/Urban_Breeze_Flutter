import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/core/services/deep_link_service.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/my_route/application/usecases/save_shared_route_usecase.dart';
import 'package:urban_breeze/features/my_route/di/my_route_providers.dart';
import 'package:urban_breeze/features/my_route/presentation/screens/my_route_detail_screen.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class RouteShareHandler with ErrorDisplayMixin {
  factory RouteShareHandler() => _instance;
  RouteShareHandler._internal();
  static final RouteShareHandler _instance = RouteShareHandler._internal();

  // 로그인하지 않은 상태에서 받은 딥링크를 임시 저장
  RouteShareCallback? _pendingRouteShare;

  // 중복 처리 방지를 위한 플래그
  bool _isProcessing = false;

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

      // 로그인 상태 확인
      final bool isLoggedIn = ref.read(isLoggedInProvider);

      if (!isLoggedIn) {
        // 로그인하지 않은 경우 딥링크를 임시 저장
        _pendingRouteShare = callback;
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
        showErrorFromAppResult(context, result as AppFailure<void>);
      }
    } catch (e) {
      if (!context.mounted) return;
      showErrorMessage(context, '공유된 경로 저장 중 오류가 발생했습니다: ${e.toString()}');
    } finally {
      _isProcessing = false;
    }
  }

  /// 로그인 완료 후 대기 중인 딥링크 처리
  static Future<void> processPendingRouteShare(
    WidgetRef ref,
    BuildContext context,
  ) async {
    if (_instance._pendingRouteShare != null) {
      final RouteShareCallback pendingCallback = _instance._pendingRouteShare!;
      _instance._pendingRouteShare = null; // 처리 후 초기화

      await _instance._processRouteShare(ref, context, pendingCallback);
    }
  }

  Future<void> _processRouteShare(
    WidgetRef ref,
    BuildContext context,
    RouteShareCallback callback,
  ) async {
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
        showErrorFromAppResult(context, result as AppFailure<void>);
      }
    } catch (e) {
      if (!context.mounted) return;
      showErrorMessage(context, '공유된 경로 저장 중 오류가 발생했습니다: ${e.toString()}');
    }
  }
}
