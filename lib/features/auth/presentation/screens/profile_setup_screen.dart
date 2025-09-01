import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urban_breeze/core/extensions/theme_extensions.dart';
import 'package:urban_breeze/navigation/navigation_scaffold.dart';
import 'package:urban_breeze/shared/design_system/tokens/semantic_colors.dart';
import 'package:urban_breeze/shared/design_system/tokens/typography/app_text_style.dart';
import 'package:urban_breeze/shared/design_system/widgets/app_bar/custom_app_bar.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_size.dart';
import 'package:urban_breeze/shared/design_system/widgets/button/button_solid.dart';

class ProfileSetupScreen extends ConsumerWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SemanticColors colors = context.semanticColor;
    return Scaffold(
      appBar: const CustomAppBar(centerTitle: true, title: '프로필 설정'),
      backgroundColor: context.semanticColor.backgroundNormalNormal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Text('프로필 설정 화면', style: AppTextStyles.heading2.bold),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ButtonSolid(
                  backgroundColor: colors.primaryNormal,
                  textColor: colors.staticWhite,
                  size: ButtonSize.large,
                  text: '가입하기',
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<Widget>(
                        builder:
                            (BuildContext context) =>
                                const NavigationScaffold(),
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
