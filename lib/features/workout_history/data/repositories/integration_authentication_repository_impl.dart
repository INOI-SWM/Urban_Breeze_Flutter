import 'package:urban_breeze/features/workout_history/data/datasources/integration_authentication_datasource.dart';
import 'package:urban_breeze/features/workout_history/data/mappers/integration_authentication_mapper.dart';
import 'package:urban_breeze/features/workout_history/data/models/integration_authentication_response_model.dart';
import 'package:urban_breeze/features/workout_history/domain/entities/integration_authentication.dart';
import 'package:urban_breeze/features/workout_history/domain/repositories/integration_authentication_repository.dart';
import 'package:urban_breeze/shared/api/data/models/api_response_model.dart';

/// 연동 인증 Repository 구현체
class IntegrationAuthenticationRepositoryImpl
    implements IntegrationAuthenticationRepository {
  const IntegrationAuthenticationRepositoryImpl({required this.dataSource});

  final IntegrationAuthenticationDataSource dataSource;

  @override
  Future<IntegrationAuthentication> requestIntegrationLink({
    required String terraProvider,
  }) async {
    final IntegrationAuthenticationApiResponse response = await dataSource
        .requestIntegrationLink(terraProvider: terraProvider);
    return IntegrationAuthenticationMapper.fromResponseModel(response.data);
  }

  @override
  Future<Map<String, dynamic>> getIntegrationActivity() async {
    final ApiResponseModel<Map<String, dynamic>> response =
        await dataSource.getIntegrationActivity();
    return response.data;
  }
}
