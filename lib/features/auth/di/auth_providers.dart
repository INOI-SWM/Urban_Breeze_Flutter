import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:urban_breeze/core/di/core_providers.dart';
import 'package:urban_breeze/features/auth/application/providers/user_session_notifier.dart';
import 'package:urban_breeze/features/auth/application/use_cases/auth_sign_in_facade.dart';
import 'package:urban_breeze/features/auth/application/use_cases/auth_sign_out_facade.dart';
import 'package:urban_breeze/features/auth/application/use_cases/auth_withdrawal_facade.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_in_with_apple_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_in_with_google_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/sign_in_with_kakao_use_case.dart';
import 'package:urban_breeze/features/auth/application/use_cases/update_agreement_use_case.dart';
import 'package:urban_breeze/features/auth/data/datasources/agreement_datasource.dart';
import 'package:urban_breeze/features/auth/data/datasources/apple_auth_datasource.dart';
import 'package:urban_breeze/features/auth/data/datasources/google_auth_datasource.dart';
import 'package:urban_breeze/features/auth/data/datasources/kakao_auth_datasource.dart';
import 'package:urban_breeze/features/auth/data/datasources/urban_breeze_auth_remote_datasource.dart';
import 'package:urban_breeze/features/auth/data/repositories/agreement_repository_impl.dart';
import 'package:urban_breeze/features/auth/data/repositories/apple_auth_repository_impl.dart';
import 'package:urban_breeze/features/auth/data/repositories/google_auth_repository_impl.dart';
import 'package:urban_breeze/features/auth/data/repositories/kakao_auth_repository_impl.dart';
import 'package:urban_breeze/features/auth/data/repositories/token_repository_impl.dart';
import 'package:urban_breeze/features/auth/data/repositories/urban_breeze_auth_repository_impl.dart';
import 'package:urban_breeze/features/auth/data/repositories/user_session_repository_impl.dart';
import 'package:urban_breeze/features/auth/domain/entities/user.dart';
import 'package:urban_breeze/features/auth/domain/entities/user_agreement.dart';
import 'package:urban_breeze/features/auth/domain/repositories/agreement_repository.dart';
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
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return UrbanBreezeAuthRemoteDataSource(client: client);
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
      final UrbanBreezeAuthRepository urbanBreezeAuthRepository = ref.watch(
        authRepositoryProvider,
      );
      return SignInWithGoogleUseCase(
        googleAuthRepository: googleAuthRepository,
        urbanBreezeAuthRepository: urbanBreezeAuthRepository,
      );
    });

final Provider<SignInWithAppleUseCase> signInWithAppleUseCaseProvider =
    Provider<SignInWithAppleUseCase>((Ref<SignInWithAppleUseCase> ref) {
      final AppleAuthRepository appleAuthRepository = ref.watch(
        appleAuthRepositoryProvider,
      );
      final UrbanBreezeAuthRepository urbanBreezeAuthRepository = ref.watch(
        authRepositoryProvider,
      );
      return SignInWithAppleUseCase(
        appleAuthRepository: appleAuthRepository,
        urbanBreezeAuthRepository: urbanBreezeAuthRepository,
      );
    });

final Provider<SignInWithKakaoUseCase> signInWithKakaoUseCaseProvider =
    Provider<SignInWithKakaoUseCase>((Ref<SignInWithKakaoUseCase> ref) {
      final KakaoAuthRepository kakaoAuthRepository = ref.watch(
        kakaoAuthRepositoryProvider,
      );
      final UrbanBreezeAuthRepository urbanBreezeAuthRepository = ref.watch(
        authRepositoryProvider,
      );
      return SignInWithKakaoUseCase(
        kakaoAuthRepository: kakaoAuthRepository,
        urbanBreezeAuthRepository: urbanBreezeAuthRepository,
      );
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
      final TokenRepository tokenRepository = ref.watch(
        tokenRepositoryProvider,
      );
      final UserSessionNotifier userSessionNotifier = ref.watch(
        userSessionNotifierProvider.notifier,
      );
      final UserAgreementNotifier userAgreementNotifier = ref.watch(
        userAgreementNotifierProvider.notifier,
      );
      final LoginInProgressNotifier loginInProgressNotifier = ref.watch(
        loginInProgressNotifierProvider.notifier,
      );

      return AuthSignInFacade(
        signInWithGoogleUseCase: signInWithGoogleUseCase,
        signInWithAppleUseCase: signInWithAppleUseCase,
        signInWithKakaoUseCase: signInWithKakaoUseCase,
        tokenRepository: tokenRepository,
        userSessionNotifier: userSessionNotifier,
        userAgreementNotifier: userAgreementNotifier,
        loginInProgressNotifier: loginInProgressNotifier,
      );
    });

final Provider<AuthSignOutFacade> authSignOutFacadeProvider =
    Provider<AuthSignOutFacade>((Ref<AuthSignOutFacade> ref) {
      final GoogleAuthRepository googleAuthRepository = ref.watch(
        googleAuthRepositoryProvider,
      );
      final AppleAuthRepository appleAuthRepository = ref.watch(
        appleAuthRepositoryProvider,
      );
      final KakaoAuthRepository kakaoAuthRepository = ref.watch(
        kakaoAuthRepositoryProvider,
      );
      final UserSessionNotifier userSessionNotifier = ref.watch(
        userSessionNotifierProvider.notifier,
      );
      final TokenRepository tokenRepository = ref.watch(
        tokenRepositoryProvider,
      );

      return AuthSignOutFacade(
        googleAuthRepository: googleAuthRepository,
        appleAuthRepository: appleAuthRepository,
        kakaoAuthRepository: kakaoAuthRepository,
        userSessionNotifier: userSessionNotifier,
        tokenRepository: tokenRepository,
      );
    });

final Provider<AuthWithdrawalFacade> authWithdrawalFacadeProvider =
    Provider<AuthWithdrawalFacade>((Ref<AuthWithdrawalFacade> ref) {
      final GoogleAuthRepository googleAuthRepository = ref.watch(
        googleAuthRepositoryProvider,
      );
      final AppleAuthRepository appleAuthRepository = ref.watch(
        appleAuthRepositoryProvider,
      );
      final KakaoAuthRepository kakaoAuthRepository = ref.watch(
        kakaoAuthRepositoryProvider,
      );
      final UserSessionNotifier userSessionNotifier = ref.watch(
        userSessionNotifierProvider.notifier,
      );
      final TokenRepository tokenRepository = ref.watch(
        tokenRepositoryProvider,
      );
      final UrbanBreezeAuthRepository urbanBreezeAuthRepository = ref.watch(
        authRepositoryProvider,
      );
      final UserAgreementNotifier userAgreementNotifier = ref.watch(
        userAgreementNotifierProvider.notifier,
      );

      return AuthWithdrawalFacade(
        googleAuthRepository: googleAuthRepository,
        appleAuthRepository: appleAuthRepository,
        kakaoAuthRepository: kakaoAuthRepository,
        userSessionNotifier: userSessionNotifier,
        tokenRepository: tokenRepository,
        urbanBreezeAuthRepository: urbanBreezeAuthRepository,
        userAgreementNotifier: userAgreementNotifier,
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

// 로그인 진행 중 상태 Provider
final StateNotifierProvider<LoginInProgressNotifier, bool>
loginInProgressNotifierProvider =
    StateNotifierProvider<LoginInProgressNotifier, bool>(
      (Ref ref) => LoginInProgressNotifier(),
    );

// UserAgreement Providers
final StateNotifierProvider<UserAgreementNotifier, UserAgreement?>
userAgreementNotifierProvider =
    StateNotifierProvider<UserAgreementNotifier, UserAgreement?>((Ref ref) {
      final UserSessionRepository repository = ref.watch(
        userSessionRepositoryProvider,
      );
      return UserAgreementNotifier(repository: repository);
    });

final Provider<bool> shouldShowConsentScreenProvider = Provider<bool>((
  Ref<bool> ref,
) {
  final User? user = ref.watch(userSessionNotifierProvider);
  final UserAgreement? agreement = ref.watch(userAgreementNotifierProvider);
  final bool loginInProgress = ref.watch(loginInProgressNotifierProvider);

  // 로그인 진행 중이면 동의 창을 표시하지 않음 (깜빡임 방지)
  if (loginInProgress) {
    return false;
  }

  // 로그인되어 있지만 약관 동의가 완료되지 않은 경우 동의 창 표시
  return user != null && (agreement == null || !agreement.isCompleted);
});

// Agreement Providers
final Provider<AgreementDataSource> agreementDataSourceProvider =
    Provider<AgreementDataSource>((Ref ref) {
      final http.Client client = ref.watch(authorizedHttpClientProvider);
      return AgreementDataSource(client: client);
    });

final Provider<AgreementRepository> agreementRepositoryProvider =
    Provider<AgreementRepository>((Ref ref) {
      final AgreementDataSource dataSource = ref.watch(
        agreementDataSourceProvider,
      );
      return AgreementRepositoryImpl(dataSource: dataSource);
    });

final Provider<UpdateAgreementUseCase> updateAgreementUseCaseProvider =
    Provider<UpdateAgreementUseCase>((Ref ref) {
      final AgreementRepository repository = ref.watch(
        agreementRepositoryProvider,
      );
      return UpdateAgreementUseCase(repository: repository);
    });
