import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/features/auth/application/providers/user_session_notifier.dart';
import 'package:urban_breeze/features/auth/application/use_cases/auth_sign_in_facade.dart';
import 'package:urban_breeze/features/auth/application/use_cases/auth_sign_out_facade.dart';
import 'package:urban_breeze/features/auth/application/use_cases/auth_withdrawal_facade.dart';
import 'package:urban_breeze/features/auth/application/use_cases/login_with_apple_idtoken_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/login_with_google_idtoken_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/login_with_kakao_access_token_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_in_with_apple_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_in_with_google_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_in_with_kakao_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_out_with_apple_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_out_with_google_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_out_with_kakao_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/withdraw_with_apple_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/withdraw_with_google_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/withdraw_with_kakao_use_case.dart';
import 'package:urban_breeze/features/auth/data/datasources/apple_auth_datasource.dart';
import 'package:urban_breeze/features/auth/data/datasources/google_auth_datasource.dart';
import 'package:urban_breeze/features/auth/data/datasources/kakao_auth_datasource.dart';
import 'package:urban_breeze/features/auth/data/datasources/urban_breeze_auth_remote_datasource.dart';
import 'package:urban_breeze/features/auth/data/repositories/apple_auth_repository_impl.dart';
import 'package:urban_breeze/features/auth/data/repositories/google_auth_repository_impl.dart';
import 'package:urban_breeze/features/auth/data/repositories/kakao_auth_repository_impl.dart';
import 'package:urban_breeze/features/auth/data/repositories/token_repository_impl.dart';
import 'package:urban_breeze/features/auth/data/repositories/urban_breeze_auth_repository_impl.dart';
import 'package:urban_breeze/features/auth/data/repositories/user_session_repository_impl.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/repositories/apple_auth_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/google_auth_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/kakao_auth_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/token_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/urban_breeze_auth_repository.dart';
import 'package:urban_breeze/features/auth/domain/repositories/user_session_repository.dart';
import 'package:urban_breeze/features/profile/di/profile_providers.dart';

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

final Provider<UrbanBreezeAuthRemoteDataSource> authRemoteDataSourceProvider =
    Provider<UrbanBreezeAuthRemoteDataSource>((
      Ref<UrbanBreezeAuthRemoteDataSource> ref,
    ) {
      return UrbanBreezeAuthRemoteDataSource();
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

final Provider<UrbanBreezeAuthRepository> authRepositoryProvider =
    Provider<UrbanBreezeAuthRepository>((Ref<UrbanBreezeAuthRepository> ref) {
      final UrbanBreezeAuthRemoteDataSource remoteDataSource = ref.watch(
        authRemoteDataSourceProvider,
      );
      return UrbanBreezeAuthRepositoryImpl(remoteDataSource: remoteDataSource);
    });

final Provider<TokenRepository> tokenRepositoryProvider =
    Provider<TokenRepository>((Ref<TokenRepository> ref) {
      return TokenRepositoryImpl();
    });

// Sign In Use Case Providers
final Provider<SignInWithGoogleUseCase> signInWithGoogleUseCaseProvider =
    Provider<SignInWithGoogleUseCase>((Ref<SignInWithGoogleUseCase> ref) {
      final GoogleAuthRepository googleAuthRepository = ref.watch(
        googleAuthRepositoryProvider,
      );
      return SignInWithGoogleUseCase(repository: googleAuthRepository);
    });

final Provider<LoginWithGoogleIdTokenUseCase>
loginWithGoogleIdTokenUseCaseProvider = Provider<LoginWithGoogleIdTokenUseCase>(
  (Ref<LoginWithGoogleIdTokenUseCase> ref) {
    final UrbanBreezeAuthRepository authRepository = ref.watch(
      authRepositoryProvider,
    );
    return LoginWithGoogleIdTokenUseCase(repository: authRepository);
  },
);

final Provider<LoginWithKakaoAccessTokenUseCase>
loginWithKakaoAccessTokenUseCaseProvider =
    Provider<LoginWithKakaoAccessTokenUseCase>((
      Ref<LoginWithKakaoAccessTokenUseCase> ref,
    ) {
      final UrbanBreezeAuthRepository authRepository = ref.watch(
        authRepositoryProvider,
      );
      return LoginWithKakaoAccessTokenUseCase(repository: authRepository);
    });

final Provider<LoginWithAppleIdTokenUseCase>
loginWithAppleIdTokenUseCaseProvider = Provider<LoginWithAppleIdTokenUseCase>((
  Ref<LoginWithAppleIdTokenUseCase> ref,
) {
  final UrbanBreezeAuthRepository authRepository = ref.watch(
    authRepositoryProvider,
  );
  return LoginWithAppleIdTokenUseCase(repository: authRepository);
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

// Withdraw Use Case Providers
final Provider<WithdrawWithGoogleUseCase> withdrawWithGoogleUseCaseProvider =
    Provider<WithdrawWithGoogleUseCase>((Ref<WithdrawWithGoogleUseCase> ref) {
      final GoogleAuthRepository googleAuthRepository = ref.watch(
        googleAuthRepositoryProvider,
      );
      return WithdrawWithGoogleUseCase(repository: googleAuthRepository);
    });

final Provider<WithdrawWithAppleUseCase> withdrawWithAppleUseCaseProvider =
    Provider<WithdrawWithAppleUseCase>((Ref<WithdrawWithAppleUseCase> ref) {
      final AppleAuthRepository appleAuthRepository = ref.watch(
        appleAuthRepositoryProvider,
      );
      return WithdrawWithAppleUseCase(repository: appleAuthRepository);
    });

final Provider<WithdrawWithKakaoUseCase> withdrawWithKakaoUseCaseProvider =
    Provider<WithdrawWithKakaoUseCase>((Ref<WithdrawWithKakaoUseCase> ref) {
      final KakaoAuthRepository kakaoAuthRepository = ref.watch(
        kakaoAuthRepositoryProvider,
      );
      return WithdrawWithKakaoUseCase(repository: kakaoAuthRepository);
    });

// Facade Providers
final Provider<AuthSignInFacade> authSignInFacadeProvider =
    Provider<AuthSignInFacade>((Ref<AuthSignInFacade> ref) {
      final SignInWithGoogleUseCase signInWithGoogleUseCase = ref.watch(
        signInWithGoogleUseCaseProvider,
      );
      final LoginWithGoogleIdTokenUseCase loginWithGoogleIdTokenUseCase = ref
          .watch(loginWithGoogleIdTokenUseCaseProvider);
      final SignInWithAppleUseCase signInWithAppleUseCase = ref.watch(
        signInWithAppleUseCaseProvider,
      );
      final SignInWithKakaoUseCase signInWithKakaoUseCase = ref.watch(
        signInWithKakaoUseCaseProvider,
      );
      final LoginWithKakaoAccessTokenUseCase loginWithKakaoAccessTokenUseCase =
          ref.watch(loginWithKakaoAccessTokenUseCaseProvider);
      final LoginWithAppleIdTokenUseCase loginWithAppleIdTokenUseCase = ref
          .watch(loginWithAppleIdTokenUseCaseProvider);
      final TokenRepository tokenRepository = ref.watch(
        tokenRepositoryProvider,
      );
      final UserSessionNotifier userSessionNotifier = ref.watch(
        userSessionNotifierProvider.notifier,
      );

      return AuthSignInFacade(
        signInWithGoogleUseCase: signInWithGoogleUseCase,
        loginWithGoogleIdTokenUseCase: loginWithGoogleIdTokenUseCase,
        signInWithAppleUseCase: signInWithAppleUseCase,
        signInWithKakaoUseCase: signInWithKakaoUseCase,
        loginWithKakaoAccessTokenUseCase: loginWithKakaoAccessTokenUseCase,
        loginWithAppleIdTokenUseCase: loginWithAppleIdTokenUseCase,
        tokenRepository: tokenRepository,
        userSessionNotifier: userSessionNotifier,
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
      final UserSessionNotifier userSessionNotifier = ref.watch(
        userSessionNotifierProvider.notifier,
      );
      final TokenRepository tokenRepository = ref.watch(
        tokenRepositoryProvider,
      );

      return AuthSignOutFacade(
        signOutWithGoogleUseCase: signOutWithGoogleUseCase,
        signOutWithAppleUseCase: signOutWithAppleUseCase,
        signOutWithKakaoUseCase: signOutWithKakaoUseCase,
        userSessionNotifier: userSessionNotifier,
        tokenRepository: tokenRepository,
      );
    });

final Provider<AuthWithdrawalFacade> authWithdrawalFacadeProvider =
    Provider<AuthWithdrawalFacade>((Ref<AuthWithdrawalFacade> ref) {
      final WithdrawWithGoogleUseCase withdrawWithGoogleUseCase = ref.watch(
        withdrawWithGoogleUseCaseProvider,
      );
      final WithdrawWithAppleUseCase withdrawWithAppleUseCase = ref.watch(
        withdrawWithAppleUseCaseProvider,
      );
      final WithdrawWithKakaoUseCase withdrawWithKakaoUseCase = ref.watch(
        withdrawWithKakaoUseCaseProvider,
      );
      final UserSessionNotifier userSessionNotifier = ref.watch(
        userSessionNotifierProvider.notifier,
      );
      final TokenRepository tokenRepository = ref.watch(
        tokenRepositoryProvider,
      );

      return AuthWithdrawalFacade(
        withdrawWithGoogleUseCase: withdrawWithGoogleUseCase,
        withdrawWithAppleUseCase: withdrawWithAppleUseCase,
        withdrawWithKakaoUseCase: withdrawWithKakaoUseCase,
        userSessionNotifier: userSessionNotifier,
        tokenRepository: tokenRepository,
      );
    });

// Auth Initialization Notifier Provider
final StateNotifierProvider<AuthInitializationNotifier, bool>
authInitializationNotifierProvider =
    StateNotifierProvider<AuthInitializationNotifier, bool>(
      (Ref ref) => AuthInitializationNotifier(),
    );

// User Session Notifier Providers
final StateNotifierProvider<UserSessionNotifier, User?>
userSessionNotifierProvider = StateNotifierProvider<UserSessionNotifier, User?>(
  (Ref ref) => UserSessionNotifier(
    repository: ref.read(userSessionRepositoryProvider),
    getProfileUseCase: ref.read(getProfileUseCaseProvider),
    updateNicknameUseCase: ref.read(updateNicknameUseCaseProvider),
    updateIntroduceUseCase: ref.read(updateIntroduceUseCaseProvider),
    updateBirthUseCase: ref.read(updateBirthUseCaseProvider),
    updateGenderUseCase: ref.read(updateGenderUseCaseProvider),
    onInitialized: () {
      ref.read(authInitializationNotifierProvider.notifier).markInitialized();
    },
  ),
);

final Provider<bool> isLoggedInProvider = Provider<bool>(
  (Ref<bool> ref) => ref.watch(userSessionNotifierProvider) != null,
);

final Provider<bool> isAuthInitializedProvider = Provider<bool>(
  (Ref<bool> ref) => ref.watch(authInitializationNotifierProvider),
);
