import 'package:urban_breeze/features/workout_history/domain/entities/apple_health_connection.dart';

abstract class AppleHealthConnectRepository {
  Future<AppleHealthConnection> connectAppleHealth();
}
