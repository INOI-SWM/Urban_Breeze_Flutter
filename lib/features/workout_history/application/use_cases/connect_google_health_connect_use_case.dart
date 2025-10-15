import 'package:urban_breeze/core/exceptions/base_domain_exception.dart';
import 'package:urban_breeze/core/result/app_result.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/google_health_connect_repository.dart';

class ConnectGoogleHealthConnectUseCase {
  const ConnectGoogleHealthConnectUseCase({required this.repository});

  final GoogleHealthConnectRepository repository;

  Future<AppResult<void>> execute() async {
    try {
      await repository.connectGoogleHealthConnect();
      return const AppSuccess<void>(null);
    } catch (e) {
      return AppFailure<void>(NetworkException(e.toString()));
    }
  }
}
