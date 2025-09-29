import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/core/services/deep_link_service.dart';
import 'package:urban_breeze/features/my_route/application/usecases/save_shared_route_usecase.dart';
import 'package:urban_breeze/features/my_route/di/my_route_providers.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class RouteShareHandler {
  static void initialize(WidgetRef ref, BuildContext context) {
    DeepLinkService().routeShareStream.listen((RouteShareCallback callback) {
      if (!context.mounted) return;
      _handleRouteShare(ref, context, callback);
    });
  }

  static Future<void> _handleRouteShare(
    WidgetRef ref,
    BuildContext context,
    RouteShareCallback callback,
  ) async {
    if (!callback.isValid) {
      debugPrint('유효하지 않은 경로 공유 링크: ${callback.routeId}');
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
        ErrorDisplay.showSuccessMessage(context, '공유된 경로가 내 경로에 성공적으로 추가되었습니다');
      } else {
        ErrorDisplay.showErrorFromAppResult(
          context,
          result as AppFailure<void>,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ErrorDisplay.showErrorMessage(
        context,
        '공유된 경로 저장 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }
}
