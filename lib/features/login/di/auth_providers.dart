import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/login/application/use_cases/sign_in_with_google_use_case.dart';
import 'package:ridingmate/features/login/data/datasources/google_auth_datasource.dart';
import 'package:ridingmate/features/login/data/repositories/auth_repository_impl.dart';
import 'package:ridingmate/features/login/domain/repositories/auth_repository.dart';

final Provider<GoogleAuthDataSource> googleAuthDataSourceProvider =
    Provider<GoogleAuthDataSource>((Ref<GoogleAuthDataSource> ref) {
      return GoogleAuthDataSourceImpl();
    });

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref<AuthRepository> ref) {
      final GoogleAuthDataSource googleAuthDataSource = ref.watch(
        googleAuthDataSourceProvider,
      );
      return AuthRepositoryImpl(googleAuthDataSource: googleAuthDataSource);
    });

final Provider<SignInWithGoogleUseCase> signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>((Ref<SignInWithGoogleUseCase> ref) {
      final AuthRepository authRepository = ref.watch(authRepositoryProvider);
      return SignInWithGoogleUseCase(authRepository: authRepository);
    });
