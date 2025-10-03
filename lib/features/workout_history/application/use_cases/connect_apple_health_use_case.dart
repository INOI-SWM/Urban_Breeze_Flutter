import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/apple_health_connection.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/apple_health_connect_repository.dart';

class ConnectAppleHealthUseCase {
  const ConnectAppleHealthUseCase({required this.repository});

  final AppleHealthConnectRepository repository;

  Future<AppResult<AppleHealthConnection>> execute() async {
    try {
      final AppleHealthConnection connection =
          await repository.connectAppleHealth();
      return AppSuccess<AppleHealthConnection>(connection);
    } catch (e) {
      return AppFailure<AppleHealthConnection>(NetworkException(e.toString()));
    }
  }
}
