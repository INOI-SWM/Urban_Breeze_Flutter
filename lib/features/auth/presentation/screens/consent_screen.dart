import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_size.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_solid.dart';

class ConsentScreen extends ConsumerWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SemanticColors colors = context.semanticColor;
    return Scaffold(
      appBar: const CustomAppBar(centerTitle: true, title: '이용약관 동의'),
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Text('이용약관 동의 화면', style: AppTextStyles.heading2.bold),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ButtonSolid(
                  backgroundColor: colors.primaryNormal,
                  textColor: colors.staticWhite,
                  size: ButtonSize.large,
                  text: '계속',
                  onPressed: () {
                    // 동의 완료 후 홈화면으로 이동
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<Widget>(
                        builder:
                            (BuildContext context) =>
                                const ProfileSetupScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
