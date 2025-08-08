import 'package:ridingmate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ridingmate/features/auth/domain/repositories/ridingmate_auth_repository.dart';

class RidingMateAuthRepositoryImpl implements RidingMateAuthRepository {
  RidingMateAuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Map<String, dynamic>> loginWithGoogleIdToken({
    required String idToken,
  }) async {
    return _remoteDataSource.loginWithGoogleIdToken(idToken: idToken);
  }
}
