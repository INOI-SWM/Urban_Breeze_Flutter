import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridingmate/features/auth/application/providers/user_session_notifier.dart';
import 'package:ridingmate/features/auth/application/use_cases/auth_sign_in_facade.dart';
import 'package:ridingmate/features/auth/application/use_cases/auth_sign_out_facade.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_apple_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_google_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_in_with_kakao_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_out_with_apple_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_out_with_google_use_case.dart';
import 'package:ridingmate/features/auth/application/use_cases/sign_out_with_kakao_use_case.dart';
import 'package:ridingmate/features/auth/data/datasources/apple_auth_datasource.dart';
import 'package:ridingmate/features/auth/data/datasources/google_auth_datasource.dart';
import 'package:ridingmate/features/auth/data/datasources/kakao_auth_datasource.dart';
import 'package:ridingmate/features/auth/data/repositories/apple_auth_repository_impl.dart';
import 'package:ridingmate/features/auth/data/repositories/google_auth_repository_impl.dart';
import 'package:ridingmate/features/auth/data/repositories/kakao_auth_repository_impl.dart';
import 'package:ridingmate/features/auth/data/repositories/user_session_repository_impl.dart';
import 'package:ridingmate/features/auth/domain/entities/user.dart';
import 'package:ridingmate/features/auth/domain/repositories/apple_auth_repository.dart';
import 'package:ridingmate/features/auth/domain/repositories/google_auth_repository.dart';
import 'package:ridingmate/features/auth/domain/repositories/kakao_auth_repository.dart';
import 'package:ridingmate/features/auth/domain/repositories/user_session_repository.dart';

// User Session Repository Provider
final Provider<UserSessionRepository> userSessionRepositoryProvider =
    Provider<UserSessionRepository>((Ref<UserSessionRepository> ref) {
      return UserSessionRepositoryImpl();
    });

// DataSource Providers
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

// Repository Providers
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

// Sign In Use Case Providers
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

// Sign Out Use Case Providers
final Provider<SignOutWithGoogleUseCase> signOutWithGoogleUseCaseProvider =
    Provider<SignOutWithGoogleUseCase>((Ref<SignOutWithGoogleUseCase> ref) {
      final GoogleAuthRepository googleAuthRepository = ref.watch(
        googleAuthRepositoryProvider,
      );
      return SignOutWithGoogleUseCase(repository: googleAuthRepository);
    });

final Provider<SignOutWithAppleUseCase> signOutWithAppleUseCaseProvider =
    Provider<SignOutWithAppleUseCase>((Ref<SignOutWithAppleUseCase> ref) {
      final AppleAuthRepository appleAuthRepository = ref.watch(
        appleAuthRepositoryProvider,
      );
      return SignOutWithAppleUseCase(repository: appleAuthRepository);
    });

final Provider<SignOutWithKakaoUseCase> signOutWithKakaoUseCaseProvider =
    Provider<SignOutWithKakaoUseCase>((Ref<SignOutWithKakaoUseCase> ref) {
      final KakaoAuthRepository kakaoAuthRepository = ref.watch(
        kakaoAuthRepositoryProvider,
      );
      return SignOutWithKakaoUseCase(repository: kakaoAuthRepository);
    });

// Facade Providers
final Provider<AuthSignInFacade> authSignInFacadeProvider =
    Provider<AuthSignInFacade>((Ref<AuthSignInFacade> ref) {
      final SignInWithGoogleUseCase signInWithGoogleUseCase = ref.watch(
        signInWithGoogleUseCaseProvider,
      );
      final SignInWithAppleUseCase signInWithAppleUseCase = ref.watch(
        signInWithAppleUseCaseProvider,
      );
      final SignInWithKakaoUseCase signInWithKakaoUseCase = ref.watch(
        signInWithKakaoUseCaseProvider,
      );

      return AuthSignInFacade(
        signInWithGoogleUseCase: signInWithGoogleUseCase,
        signInWithAppleUseCase: signInWithAppleUseCase,
        signInWithKakaoUseCase: signInWithKakaoUseCase,
      );
    });

final Provider<AuthSignOutFacade> authSignOutFacadeProvider =
    Provider<AuthSignOutFacade>((Ref<AuthSignOutFacade> ref) {
      final SignOutWithGoogleUseCase signOutWithGoogleUseCase = ref.watch(
        signOutWithGoogleUseCaseProvider,
      );
      final SignOutWithAppleUseCase signOutWithAppleUseCase = ref.watch(
        signOutWithAppleUseCaseProvider,
      );
      final SignOutWithKakaoUseCase signOutWithKakaoUseCase = ref.watch(
        signOutWithKakaoUseCaseProvider,
      );

      return AuthSignOutFacade(
        signOutWithGoogleUseCase: signOutWithGoogleUseCase,
        signOutWithAppleUseCase: signOutWithAppleUseCase,
        signOutWithKakaoUseCase: signOutWithKakaoUseCase,
      );
    });

// User Session Notifier Providers
final StateNotifierProvider<UserSessionNotifier, User?>
userSessionNotifierProvider = StateNotifierProvider<UserSessionNotifier, User?>(
  (Ref ref) =>
      UserSessionNotifier(repository: ref.read(userSessionRepositoryProvider)),
);

final Provider<bool> isLoggedInProvider = Provider<bool>(
  (Ref<bool> ref) => ref.watch(userSessionNotifierProvider) != null,
);
