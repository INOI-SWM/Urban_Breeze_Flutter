import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/login/application/use_cases/sign_in_with_apple_use_case.dart';
import 'package:ridingmate/features/login/application/use_cases/sign_in_with_google_use_case.dart';
import 'package:ridingmate/features/login/application/use_cases/sign_in_with_kakao_use_case.dart';
import 'package:ridingmate/features/login/data/datasources/apple_auth_datasource.dart';
import 'package:ridingmate/features/login/data/datasources/google_auth_datasource.dart';
import 'package:ridingmate/features/login/data/datasources/kakao_auth_datasource.dart';
import 'package:ridingmate/features/login/data/repositories/apple_auth_repository_impl.dart';
import 'package:ridingmate/features/login/data/repositories/google_auth_repository_impl.dart';
import 'package:ridingmate/features/login/data/repositories/kakao_auth_repository_impl.dart';
import 'package:ridingmate/features/login/domain/repositories/apple_auth_repository.dart';
import 'package:ridingmate/features/login/domain/repositories/google_auth_repository.dart';
import 'package:ridingmate/features/login/domain/repositories/kakao_auth_repository.dart';

//  DataSource Providers
final Provider<GoogleAuthDataSource> googleAuthDataSourceProvider =
    Provider<GoogleAuthDataSource>((Ref<GoogleAuthDataSource> ref) {
      return GoogleAuthDataSourceImpl();
    });

final Provider<AppleAuthDataSource> appleAuthDataSourceProvider =
    Provider<AppleAuthDataSource>((Ref<AppleAuthDataSource> ref) {
      return AppleAuthDataSourceImpl();
    });

final Provider<KakaoAuthDataSource> kakaoAuthDataSourceProvider =
    Provider<KakaoAuthDataSource>((Ref<KakaoAuthDataSource> ref) {
      return KakaoAuthDataSourceImpl();
    });

//  Repository Providers
final Provider<GoogleAuthRepository> googleAuthRepositoryProvider =
    Provider<GoogleAuthRepository>((Ref<GoogleAuthRepository> ref) {
      final GoogleAuthDataSource googleAuthDataSource = ref.watch(
        googleAuthDataSourceProvider,
      );
      return GoogleAuthRepositoryImpl(
        googleAuthDataSource: googleAuthDataSource,
      );
    });

final Provider<AppleAuthRepository> appleAuthRepositoryProvider =
    Provider<AppleAuthRepository>((Ref<AppleAuthRepository> ref) {
      final AppleAuthDataSource appleAuthDataSource = ref.watch(
        appleAuthDataSourceProvider,
      );
      return AppleAuthRepositoryImpl(appleAuthDataSource: appleAuthDataSource);
    });

final Provider<KakaoAuthRepository> kakaoAuthRepositoryProvider =
    Provider<KakaoAuthRepository>((Ref<KakaoAuthRepository> ref) {
      final KakaoAuthDataSource kakaoAuthDataSource = ref.watch(
        kakaoAuthDataSourceProvider,
      );
      return KakaoAuthRepositoryImpl(kakaoAuthDataSource: kakaoAuthDataSource);
    });

//  Use Case Providers
final Provider<SignInWithGoogleUseCase> signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>((Ref<SignInWithGoogleUseCase> ref) {
      final GoogleAuthRepository googleAuthRepository = ref.watch(
        googleAuthRepositoryProvider,
      );
      return SignInWithGoogleUseCase(repository: googleAuthRepository);
    });

final Provider<SignInWithAppleUseCase> signInWithAppleUseCaseProvider =
    Provider<SignInWithAppleUseCase>((Ref<SignInWithAppleUseCase> ref) {
      final AppleAuthRepository appleAuthRepository = ref.watch(
        appleAuthRepositoryProvider,
      );
      return SignInWithAppleUseCase(repository: appleAuthRepository);
    });

final Provider<SignInWithKakaoUseCase> signInWithKakaoUseCaseProvider =
    Provider<SignInWithKakaoUseCase>((Ref<SignInWithKakaoUseCase> ref) {
      final KakaoAuthRepository kakaoAuthRepository = ref.watch(
        kakaoAuthRepositoryProvider,
      );
      return SignInWithKakaoUseCase(repository: kakaoAuthRepository);
    });
