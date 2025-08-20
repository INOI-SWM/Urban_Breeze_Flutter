import 'package:urban_breeze/features/auth/data/datasources/urban_breeze_auth_remote_datasource.dart';
import 'package:urban_breeze/features/auth/data/models/urban_breeze_login_response_model.dart';
import 'package:urban_breeze/features/auth/domain/entities/auth_login_result.dart';
import 'package:urban_breeze/features/auth/domain/repositories/urban_breeze_auth_repository.dart';

class UrbanBreezeAuthRepositoryImpl implements UrbanBreezeAuthRepository {
  UrbanBreezeAuthRepositoryImpl({
    required UrbanBreezeAuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final UrbanBreezeAuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthLoginResult> loginWithGoogleIdToken({
    required String idToken,
  }) async {
    final UrbanBreezeLoginResponseModel model = await _remoteDataSource
        .loginWithGoogleIdToken(idToken: idToken);
    return model.toDomain();
  }

  @override
  Future<AuthLoginResult> loginWithKakaoAccessToken({
    required String accessToken,
  }) async {
    final UrbanBreezeLoginResponseModel model = await _remoteDataSource
        .loginWithKakaoAccessToken(accessToken: accessToken);
    return model.toDomain();
  }

  @override
  Future<AuthLoginResult> loginWithAppleIdToken({
    required String idToken,
  }) async {
    final UrbanBreezeLoginResponseModel model = await _remoteDataSource
        .loginWithAppleIdToken(idToken: idToken);
    return model.toDomain();
  }
}
