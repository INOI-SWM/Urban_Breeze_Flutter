import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/auth/application/use_cases/auth_withdrawal_facade.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';

class AccountManagementController {
  AccountManagementController(this._ref);

  final Ref _ref;

  Future<void> withdraw() async {
    final User? user = _ref.read(userSessionNotifierProvider);
    if (user == null) {
      throw StateError('로그인이 필요합니다.');
    }

    final AuthWithdrawalFacade authWithdrawalFacade = _ref.read(
      authWithdrawalFacadeProvider,
    );

    final AppResult<void> result = await authWithdrawalFacade.execute(
      user.loginProvider,
    );

    if (result.isFailure) {
      throw Exception(result.exceptionOrNull?.toString());
    }

    // 탈퇴 성공 후 로컬 세션 정리
    await authWithdrawalFacade.clearLocalSession();
  }
}

final Provider<AccountManagementController>
accountManagementControllerProvider = Provider<AccountManagementController>(
  (Ref ref) => AccountManagementController(ref),
);
