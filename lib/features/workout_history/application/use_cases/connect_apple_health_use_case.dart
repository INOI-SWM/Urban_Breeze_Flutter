import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/apple_health_connect_repository.dart';

class ConnectAppleHealthUseCase {
  const ConnectAppleHealthUseCase({required this.repository});

  final AppleHealthConnectRepository repository;

  Future<AppResult<void>> execute() async {
    try {
      await repository.connectAppleHealth();
      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(NetworkException(e.toString()));
    }
  }
}
