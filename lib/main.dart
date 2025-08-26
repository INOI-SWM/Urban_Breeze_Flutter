import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:urban_breeze/core/amplitude/amplitude_service.dart';
import 'package:urban_breeze/core/theme/app_theme.dart';
import 'package:urban_breeze/features/auth/di/auth_providers.dart';
import 'package:urban_breeze/features/auth/presentation/screens/login_screen.dart';
import 'package:urban_breeze/navigation/navigation_scaffold.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/screens/splash_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: '.env');
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  try {
    await AmplitudeService.instance.initialize();
  } catch (e) {
    debugPrint('Amplitude 초기화 실패: $e');
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAuthInitialized = ref.watch(isAuthInitializedProvider);
    final bool isLoggedIn = ref.watch(isLoggedInProvider);

    return MaterialApp(
      title: 'Urban Breeze',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorKey: navigatorKey,
      home:
          !isAuthInitialized
              ? const SplashScreen()
              : isLoggedIn
              ? const NavigationScaffold()
              : const LoginScreen(),
      builder: (BuildContext context, Widget? child) {
        final SemanticColors semanticColors = AppTheme.getSemanticColors(
          Theme.of(context).brightness,
        );

        return SemanticTheme(data: semanticColors, child: child!);
      },
    );
  }
}
