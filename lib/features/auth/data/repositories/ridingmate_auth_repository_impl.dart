import 'package:ridingmate/features/auth/data/datasources/ridingmate_auth_remote_datasource.dart';
import 'package:ridingmate/features/auth/data/models/ridingmate_login_response_model.dart';
import 'package:ridingmate/features/auth/domain/entities/auth_login_result.dart';
import 'package:ridingmate/features/auth/domain/repositories/ridingmate_auth_repository.dart';

class RidingMateAuthRepositoryImpl implements RidingMateAuthRepository {
  RidingMateAuthRepositoryImpl({
    required RidingMateAuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final RidingMateAuthRemoteDataSource _remoteDataSource;

  @override
  Future<AuthLoginResult> loginWithGoogleIdToken({
    required String idToken,
  }) async {
    final RidingMateLoginResponseModel model = await _remoteDataSource
        .loginWithGoogleIdToken(idToken: idToken);
    return model.toDomain();
  }

  @override
  Future<AuthLoginResult> loginWithKakaoAccessToken({
    required String accessToken,
  }) async {
    final RidingMateLoginResponseModel model = await _remoteDataSource
        .loginWithKakaoAccessToken(accessToken: accessToken);
    return model.toDomain();
  }
}
