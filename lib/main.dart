import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:urban_breeze/core/amplitude/amplitude_service.dart';
import 'package:urban_breeze/core/config/environment_config.dart';
import 'package:urban_breeze/core/services/app_tracking_service.dart';
import 'package:urban_breeze/core/services/deep_link_service.dart';
import 'package:urban_breeze/core/theme/app_theme.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/presentation/screens/consent_screen.dart';
import 'package:urban_breeze/features/auth/presentation/screens/login_screen.dart';
import 'package:urban_breeze/navigation/navigation_scaffold.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/screens/splash_screen.dart';

import 'firebase_options.dart';
import 'firebase_options_dev.dart';
import 'firebase_options_prod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경에 따른 Firebase 설정 선택
  final FirebaseOptions firebaseOptions = _getFirebaseOptions();
  await Firebase.initializeApp(options: firebaseOptions);

  // EnvironmentConfig에서 Kakao Native App Key 사용
  KakaoSdk.init(nativeAppKey: EnvironmentConfig.kakaoNativeAppKey);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  try {
    await AppTrackingService.instance.requestTrackingAuthorization();
  } catch (e) {
    debugPrint('ATT 권한 요청 실패: $e');
  }

  try {
    await AmplitudeService.instance.initialize();
  } catch (e) {
    debugPrint('Amplitude 초기화 실패: $e');
  }

  try {
    await DeepLinkService().initialize();
  } catch (e) {
    debugPrint('Deep Link 초기화 실패: $e');
  }

  runApp(RestartableApp(key: restartableAppKey));
}

// 앱 재시작을 위한 GlobalKey
final GlobalKey<RestartableAppState> restartableAppKey =
    GlobalKey<RestartableAppState>();

class RestartableApp extends StatefulWidget {
  const RestartableApp({super.key});

  @override
  State<RestartableApp> createState() => RestartableAppState();
}

class RestartableAppState extends State<RestartableApp> {
  Key providerScopeKey = UniqueKey();
  Key myAppKey = UniqueKey();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void restart() {
    setState(() {
      providerScopeKey = UniqueKey();
      myAppKey = UniqueKey();
      navigatorKey = GlobalKey<NavigatorState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: providerScopeKey,
      child: MyApp(key: myAppKey, navigatorKey: navigatorKey),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  Widget _buildHomeScreen({
    required bool isAuthInitialized,
    required bool isLoggedIn,
    required bool shouldShowConsent,
  }) {
    if (!isAuthInitialized) {
      return const SplashScreen();
    }

    if (!isLoggedIn) {
      return const LoginScreen();
    }

    // 약관동의가 완료되지 않은 경우 동의창으로 이동
    if (shouldShowConsent) {
      return const ConsentScreen();
    }

    return const NavigationScaffold();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAuthInitialized = ref.watch(isAuthInitializedProvider);
    final bool isLoggedIn = ref.watch(isLoggedInProvider);
    final bool shouldShowConsent = ref.watch(shouldShowConsentScreenProvider);

    return MaterialApp(
      title: 'Urban Breeze',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorKey: navigatorKey,
      home: _buildHomeScreen(
        isAuthInitialized: isAuthInitialized,
        isLoggedIn: isLoggedIn,
        shouldShowConsent: shouldShowConsent,
      ),
      builder: (BuildContext context, Widget? child) {
        final SemanticColors semanticColors = AppTheme.getSemanticColors(
          Theme.of(context).brightness,
        );

        return SemanticTheme(data: semanticColors, child: child!);
      },
    );
  }
}

/// 환경에 따른 Firebase 설정을 반환하는 함수
FirebaseOptions _getFirebaseOptions() {
  // EnvironmentConfig가 초기화되었는지 확인
  try {
    final Environment environment = EnvironmentConfig.environment;
    switch (environment) {
      case Environment.dev:
        return DefaultFirebaseOptionsDev.currentPlatform;
      case Environment.prod:
        return DefaultFirebaseOptionsProd.currentPlatform;
      default:
        // 기본값으로 프로덕션 설정 사용
        return DefaultFirebaseOptionsProd.currentPlatform;
    }
  } catch (e) {
    // EnvironmentConfig가 아직 초기화되지 않은 경우 기본값 사용
    return DefaultFirebaseOptions.currentPlatform;
  }
}
