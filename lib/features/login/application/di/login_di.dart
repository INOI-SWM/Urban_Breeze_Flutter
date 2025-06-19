import 'package:ridingmate/features/login/application/use_cases/sign_in_with_google_use_case.dart';
import 'package:ridingmate/features/login/data/datasources/google_auth_datasource.dart';
import 'package:ridingmate/features/login/data/repositories/auth_repository_impl.dart';
import 'package:ridingmate/features/login/domain/repositories/auth_repository.dart';

class LoginDI {
  LoginDI._();
  static final LoginDI instance = LoginDI._();

  late final GoogleAuthDataSource _googleAuthDataSource;
  late final AuthRepository _authRepository;
  late final SignInWithGoogleUseCase _signInWithGoogleUseCase;

  void init() {
    _googleAuthDataSource = GoogleAuthDataSourceImpl();

    _authRepository = AuthRepositoryImpl(
      googleAuthDataSource: _googleAuthDataSource,
    );

    _signInWithGoogleUseCase = SignInWithGoogleUseCase(
      authRepository: _authRepository,
    );
  }

  SignInWithGoogleUseCase get signInWithGoogleUseCase =>
      _signInWithGoogleUseCase;
  AuthRepository get authRepository => _authRepository;
}
