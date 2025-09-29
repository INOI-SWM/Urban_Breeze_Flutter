import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/core/services/deep_link_service.dart';
import 'package:urban_breeze/features/my_route/application/usecases/save_shared_route_usecase.dart';
import 'package:urban_breeze/features/my_route/di/my_route_providers.dart';
import 'package:urban_breeze/features/my_route/presentation/screens/my_route_detail_screen.dart';
import 'package:urban_breeze/shared/mixins/error_display_mixin.dart';

class RouteShareHandler with ErrorDisplayMixin {
  factory RouteShareHandler() => _instance;
  RouteShareHandler._internal();
  static final RouteShareHandler _instance = RouteShareHandler._internal();

  static void initialize(WidgetRef ref, BuildContext context) {
    DeepLinkService().routeShareStream.listen((RouteShareCallback callback) {
      if (!context.mounted) return;
      _instance._handleRouteShare(ref, context, callback);
    });
  }

  Future<void> _handleRouteShare(
    WidgetRef ref,
    BuildContext context,
    RouteShareCallback callback,
  ) async {
    if (!callback.isValid) return;

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
