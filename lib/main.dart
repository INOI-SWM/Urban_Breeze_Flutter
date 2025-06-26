import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:ridingmate/core/theme/app_theme.dart';
import 'package:ridingmate/features/auth/application/providers/user_session_notifier.dart';
import 'package:ridingmate/navigation/navigation_scaffold.dart';
import 'package:ridingmate/shared/design_system/tokens/semantic_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(userSessionProvider);

    return MaterialApp(
      title: 'Riding Mate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const NavigationScaffold(),
      builder: (BuildContext context, Widget? child) {
        final SemanticColors semanticColors = AppTheme.getSemanticColors(
          Theme.of(context).brightness,
        );

        return SemanticTheme(data: semanticColors, child: child!);
      },
    );
  }
}
